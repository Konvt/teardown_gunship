--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti = require( 'libs.lurti' )
local physics = {}

--- @class RayHit : Object
--- @field is_hit boolean
--- @field distance number
--- @field normal SpaceVec
physics.RayHit = lurti.core.meta.class()

--- @param is_hit boolean
--- @param distance number
--- @param normal SpaceVec
--- @return self
function physics.RayHit:init( is_hit, distance, normal )
  lurti.core.meta.init_super( physics.RayHit, self )
  self.is_hit = is_hit
  self.distance = distance
  self.normal = normal
  return self
end

--- @param position Coord
--- @param direction SpaceVec An unit vector.
--- @param max_distance number
--- @param ignore_objs? Handle[]
--- @return RayHit
function physics.RayHit.hit_detect( position, direction, max_distance, ignore_objs )
  ignore_objs = ignore_objs or {}
  for i = 1, #ignore_objs do
    QueryRejectBody( ignore_objs[i] )
  end
  local hit, dist, normal, _ = QueryRaycast( position, direction, max_distance )
  return physics.RayHit:new( hit, dist, normal )
end

--- @param origin Coord
--- @param radius number
--- @param force_strength number
--- @param mass_limit number
--- @param ignore_objs? Handle[] List of bodies ignored by shockwave when applying force.
--- @return nil
function physics.spawn_shockwave( origin, radius, force_strength, mass_limit, ignore_objs )
  local min_corner = VecAdd( origin, Vec( -radius / 2, -1, -radius / 2 ) )
  local max_corner = VecAdd( origin, Vec( radius / 2, 2, radius / 2 ) )

  QueryRequire( 'physical dynamic' )
  ignore_objs = ignore_objs or {}
  for i = 1, #ignore_objs do
    local body = ignore_objs[i]
    --- @cast body Handle
    QueryRejectBody( body )
  end

  local hit_bodies = QueryAabbBodies( min_corner, max_corner )
  for i = 1, #hit_bodies do
    local body = hit_bodies[i]
    local min_bound, max_bound = GetBodyBounds( body )
    local center = VecLerp( min_bound, max_bound, 0.5 )
    local direction = VecSub( center, origin )
    local dist = VecLength( direction )
    direction = VecScale( direction, 1.0 / dist )
    direction[2] = 0.5
    direction = VecNormalize( direction )

    local mass = GetBodyMass( body )
    local mass_fac = 1 - math.min( mass / mass_limit, 1.0 )
    local dist_fac = 1 - math.min( dist / radius, 1.0 )
    local impulse = VecScale( direction, force_strength * mass_fac * dist_fac )

    local vel = GetBodyVelocity( body )
    SetBodyVelocity( body, VecAdd( vel, impulse ) )
  end
end

return physics
