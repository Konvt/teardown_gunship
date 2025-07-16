--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti           = require( 'libs.lurti' )
local timer           = require( 'scripts.types.timer' )
local projectile      = {}

--- @class Projectile : Object, ICopyable
--- @field shell Ammo | nil
--- @field position Coord | nil
--- @field velocity SpaceVec | nil
--- @field vox_body Handle | nil
--- @field lifetime CountdownTimer
--- @field alive boolean
projectile.Projectile = lurti.core.meta.class( lurti.core.abc.ICopyable )

--- @param lifetime? DeltaTime
--- @param shell? Ammo
--- @return self
function projectile.Projectile:init( shell, lifetime )
  lurti.core.meta.init_super( projectile.Projectile, self )
  self.shell = shell
  self.position = nil
  self.velocity = nil
  self.vox_body = nil
  self.lifetime = timer.CountdownTimer:new( lifetime or 20 ):unwrap()
  self.alive = false
  return self
end

--- @return self
function projectile.Projectile:clone()
  local obj_cp = projectile.Projectile:new( self.shell, self.lifetime:period() )
  obj_cp.position = self.position
  obj_cp.velocity = self.velocity
  obj_cp.vox_body = self.vox_body
  obj_cp.alive = self.alive
  return obj_cp
end

--- @return nil
function projectile.Projectile:reset()
  self.shell = nil
  self.position = nil
  self.velocity = nil
  self.vox_body = nil
  self.lifetime:reset()
  self.alive = false
end

--- @param shell Ammo
--- @param pos Coord
--- @param vel SpaceVec
--- @param lifetime? DeltaTime
--- @param vox_body? Handle
--- @return nil
function projectile.Projectile:reset_with( shell, pos, vel, lifetime, vox_body )
  self.shell = shell
  self.position = pos
  self.velocity = vel
  self.lifetime = timer.CountdownTimer:new( lifetime or 20 ):unwrap()
  self.vox_body = vox_body
  self.alive = true
end

--- @param dt DeltaTime
--- @param ignored? Handle[] Objects that need to be ignored when calculating physical effects.
--- @return nil
function projectile.Projectile:during_flight( dt, ignored )
  --[[
  assert( self.shell ~= nil )
  assert( self.position ~= nil )
  assert( self.velocity ~= nil )
  assert( self.vox_body ~= nil )
  ]]
  local next_vel = self.shell:predict_velocity( dt, self.velocity )
  local next_pos = VecAdd( self.position, VecScale( next_vel, dt ) )
  self.alive = self.shell:during_flight(
    {
      dt = dt,
      pos = self.position,
      dir = VecNormalize( VecSub( next_pos, self.position ) ),
      ignored = ignored or {},
    },
    next_pos,
    self.vox_body
  )
  if self.alive then
    self.position = next_pos
    self.direction = next_vel
  end
end

return projectile
