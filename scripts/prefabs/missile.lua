--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti           = require( 'libs.lurti' )
local util            = require( 'scripts.utils.util' )
local armament        = require( 'scripts.types.armament' )
local physics         = require( 'scripts.types.physics' )
local sound           = require( 'scripts.types.sound' )
local projectile_pool = require( 'scripts.prefabs.projectile_pool' )
local projectile_mgr  = require( 'scripts.prefabs.projectile_mgr' )

--- @package
--- @class Missile : LaunchableAmmo
--- @field sprite Handle
local Missile         = lurti.core.object.class( armament.LaunchableAmmo )

--- @param name string
--- @param sprite Handle
--- @return self
function Missile:init( name, sprite )
  lurti.core.object.init_super( Missile, self, name )
  self.sprite = sprite
  return self
end

--- @param pos Coord Current position
--- @param next_pos Coord Next position
function Missile:draw_sprite( pos, next_pos )
  local rot = QuatLookAt( pos, next_pos )
  local spritepos = TransformToParentPoint( Transform( pos, rot ), Vec( 0, 0, -1 ) )
  rot = QuatRotateQuat( rot, QuatEuler( -90, 0, 0 ) )
  local transform = Transform( spritepos, rot )
  DrawSprite( self.sprite, transform, 0.45, 1, 1, 1, 1, 1, true, false )
end

--- @param pos Coord
--- @param dir SpaceVec The direction of the wake flame ejection, it should be a unit vector.
--- @return nil
function Missile.spwan_wakeflame( pos, dir )
  ParticleReset()
  ParticleType( 'smoke' )
  -- trail smoke
  ParticleAlpha( 1, 0.6 )
  ParticleDrag( 0.1, 0 )
  ParticleRadius( util.random( 0.3, 0.4 ), util.random( 0.4, 0.5 ) )
  ParticleColor( 0.67, 0.67, 0.67 )
  for _ = 1, 10 do
    SpawnParticle( pos, VecScale( dir, 1 ), 10 )
  end
  -- jet flame
  ParticleAlpha( 1, 0.3 )
  ParticleDrag( 0.3, 0 )
  ParticleRadius( util.random( 0.3, 0.4 ), util.random( 0.5, 0.7 ) )
  ParticleEmissive( util.random( 2, 3 ), 0, 'easeout' )
  ParticleColor( 0.95, 0.61, 0.07,
                 0.67, 0.67, 0.67 )
  for _ = 1, 5 do
    SpawnParticle( pos, VecScale( dir, 3 ), 1 )
  end
end

--- @param pos Coord
--- @param dir SpaceVec
--- @param snd Sound
--- @return nil
function Missile:fire( pos, dir, snd )
  --- @type Projectile
  local prjctle = projectile_pool:pop()
  dir = VecScale( dir, 1 )
  prjctle:reset_with( self, pos, dir )
  projectile_mgr:commit( prjctle )
  snd:play( pos, 0.4 )
end

--- @package
--- @class Griffin : Missile
local TNW = lurti.core.object.class( Missile )

--- Radius, center of the sphere and direction
--- @type [number, Coord][]
TNW.explosions = {
  { 4, Vec( -5.6000000000000005, -5.6000000000000005, -5.6000000000000005 ) },
  { 4, Vec( -5.6000000000000005, -5.6000000000000005, 1.5999999999999996 ) },
  { 4, Vec( -5.6000000000000005, -5.6000000000000005, 8.8 ) },
  { 4, Vec( -5.6000000000000005, 1.5999999999999996, -5.6000000000000005 ) },
  { 4, Vec( -5.6000000000000005, 1.5999999999999996, 1.5999999999999996 ) },
  { 4, Vec( -5.6000000000000005, 1.5999999999999996, 8.8 ) },
  { 4, Vec( -5.6000000000000005, 8.8, -5.6000000000000005 ) },
  { 4, Vec( -5.6000000000000005, 8.8, 1.5999999999999996 ) },
  { 4, Vec( 1.5999999999999996, -5.6000000000000005, -5.6000000000000005 ) },
  { 4, Vec( 1.5999999999999996, -5.6000000000000005, 1.5999999999999996 ) },
  { 4, Vec( 1.5999999999999996, -5.6000000000000005, 8.8 ) },
  { 4, Vec( 1.5999999999999996, 1.5999999999999996, -5.6000000000000005 ) },
  { 4, Vec( 1.5999999999999996, 1.5999999999999996, 1.5999999999999996 ) },
  { 4, Vec( 1.5999999999999996, 1.5999999999999996, 8.8 ) },
  { 4, Vec( 1.5999999999999996, 8.8, -5.6000000000000005 ) },
  { 4, Vec( 1.5999999999999996, 8.8, 1.5999999999999996 ) },
  { 4, Vec( 8.8, -5.6000000000000005, -5.6000000000000005 ) },
  { 4, Vec( 8.8, -5.6000000000000005, 1.5999999999999996 ) },
  { 4, Vec( 8.8, 1.5999999999999996, -5.6000000000000005 ) },
  { 4, Vec( 8.8, 1.5999999999999996, 1.5999999999999996 ) },
  { 4, Vec( -0.8000000000000003, -0.8000000000000003, -0.8000000000000003 ) },
  { 4, Vec( -0.8000000000000003, -0.8000000000000003, 6.4 ) },
  { 4, Vec( -0.8000000000000003, 6.4, -0.8000000000000003 ) },
  { 4, Vec( 6.4, -0.8000000000000003, -0.8000000000000003 ) },
}

--- @generic T
--- @param context Context
--- @param next_pos Coord
--- @param self_vox? Handle
--- @return boolean
function TNW:during_flight( context, next_pos, self_vox )
  local hit_info = physics.RayHit.hit_detect( context.pos,
                                              context.dir,
                                              VecLength( VecSub( next_pos, context.pos ) ),
                                              context.ignored )
  if hit_info.is_hit then
    local hit_pos = VecAdd( context.pos, VecScale( context.dir, hit_info.distance ) )
    --[[
      Here, an occlusion test should have been conducted for the objects around the explosion point,
      but it seems unnecessary.
    ]]
    for _, explosion in ipairs( TNW.explosions ) do
      Explosion( VecAdd( hit_pos, explosion[2] ), explosion[1] )
    end
  end
  self:draw_sprite( context.pos, next_pos )
  Missile.spwan_wakeflame( context.pos, VecScale( context.dir, -1 ) )
  return not hit_info.is_hit
end

--- @package
--- @class Cluster : Ammo
--- @field sprite Handle
local Cluster = lurti.core.object.class( armament.Ammo )
Cluster.gravity = Vec( 0, -30, 0 )

--- @param name string
--- @param sprite Handle
--- @return self
function Cluster:init( name, sprite )
  lurti.core.object.init_super( Cluster, self, name )
  self.sprite = sprite
  return self
end

--- @generic T
--- @param dt DeltaTime
--- @param velocity SpaceVec
--- @return SpaceVec
function Cluster:predict_velocity( dt, velocity )
  -- simulate gravity
  return VecAdd( velocity, VecScale( Cluster.gravity, dt ) )
end

--- @generic T
--- @param context Context
--- @param next_pos Coord
--- @param self_vox? Handle
--- @return boolean is_alive
function Cluster:during_flight( context, next_pos, self_vox )
  local hit_info = physics.RayHit.hit_detect( context.pos,
                                              context.dir,
                                              VecLength( VecSub( next_pos, context.pos ) ),
                                              context.ignored )
  if hit_info.is_hit then
    local hit_pos = VecAdd( context.pos, VecScale( context.dir, hit_info.distance ) )
    Explosion( hit_pos, 1 )
  end
  ParticleReset()
  ParticleType( 'smoke' )
  ParticleRadius( util.random( 0.05, 0.07 ), util.random( 0.01, 0.03 ) )
  SpawnParticle( context.pos, Vec( 0, 0, 0 ), 0.25 )

  local rot = QuatLookAt( context.pos, next_pos )
  local spritepos = TransformToParentPoint( Transform( context.pos, rot ), Vec( 0, 0, -1 ) )
  rot = QuatRotateQuat( rot, QuatEuler( -90, 0, 0 ) )
  local transform = Transform( spritepos, rot )
  DrawSprite( self.sprite, transform, 0.25, 0.25, 1, 1, 1, 1, true, false )
  return not hit_info.is_hit
end

--- @package
--- @class AirBurst : Missile
local AirBurst = lurti.core.object.class( Missile )
AirBurst.cluster = Cluster:new( 'Cluster',
                                LoadSprite( 'MOD/images/bullet_cluster.png' ) )
AirBurst.max_divergence_angle = math.pi / 6
AirBurst.min_divergence_angle = 0
AirBurst.cluster_amount = 60

--- @generic T
--- @param context Context
--- @param next_pos Coord
--- @param self_vox? Handle
--- @return boolean
function AirBurst:during_flight( context, next_pos, self_vox )
  local hit_info = physics.RayHit.hit_detect( context.pos,
                                              context.dir,
                                              15,
                                              context.ignored )
  if hit_info.is_hit then
    Explosion( context.pos, 0.5 )
    for _ = 1, AirBurst.cluster_amount do
      local cluster_vel = VecScale(
        util.rd_axis_dir( context.dir,
                          AirBurst.max_divergence_angle,
                          AirBurst.min_divergence_angle ):unwrap(),
        util.random( 35, 40 ) )
      --- @type Projectile
      local prjctle = projectile_pool:pop()
      prjctle:reset_with( AirBurst.cluster, context.pos, cluster_vel )
      projectile_mgr:commit( prjctle )
    end
  end
  self:draw_sprite( context.pos, next_pos )
  Missile.spwan_wakeflame( context.pos, VecScale( context.dir, -1 ) )
  return not hit_info.is_hit
end

--- @package
local texture = LoadSprite( 'MOD/images/bullet_missile.png' )

return armament.Weapon:new(
  'Missile',
  60,
  {
    AirBurst:new(
      'Airburst',
      texture
    ),
    TNW:new(
      'TNW',
      texture
    ),
  },
  'MOD/images/crosshair_missile.png',
  sound.Sound:new( LoadSound( 'MOD/images/shot_missile.ogg' ) )
)
