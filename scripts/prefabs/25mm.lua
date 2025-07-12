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
--- @class Bullet25mm : LaunchableAmmo
--- @field sprite Handle
--- @field hit_snd Sound | nil
local Bullet25mm      = lurti.core.object.class( armament.LaunchableAmmo )

--- @param name string
--- @param sprite Handle
--- @param hit_snd Sound | nil
--- @return self
function Bullet25mm:init( name, sprite, hit_snd )
  lurti.core.object.init_super( Bullet25mm, self, name )
  self.sprite = sprite
  self.hit_snd = hit_snd
  return self
end

--- @package
--- @return nil
function Bullet25mm.spwan_wakeflame( pos )
  ParticleReset()
  ParticleType( 'smoke' )
  ParticleRadius( util.random( 0.05, 0.1 ), util.random( 0.01, 0.03 ) )
  SpawnParticle( pos, Vec( 0, 0, 0 ), 0.25 )
end

--- @param pos Coord Current position
--- @param next_pos Coord Next position
function Bullet25mm:draw_sprite( pos, next_pos )
  local rot = QuatLookAt( pos, next_pos )
  local spritepos = TransformToParentPoint( Transform( pos, rot ), Vec( 0, 0, -1 ) )
  rot = QuatRotateQuat( rot, QuatEuler( -90, 0, 0 ) )
  local transform = Transform( spritepos, rot )
  DrawSprite( self.sprite, transform, 0.35, 1, 1, 1, 1, 1, true, false )
end

--- @param pos Coord
--- @param dir SpaceVec
--- @param snd Sound
--- @return nil
function Bullet25mm:fire( pos, dir, snd )
  --- @type Projectile
  local prjctle = projectile_pool:pop()
  dir = VecScale( dir, 3 )
  prjctle:reset_with( self, pos, dir )
  projectile_mgr:commit( prjctle )
  snd:play( pos, 0.4 )
end

--- @package
--- @class FMJ25mm : Bullet25mm
local FMJ25mm = lurti.core.object.class( Bullet25mm )

--- @param context Context
--- @param next_pos Coord
--- @param self_vox? Handle
--- @return boolean
function FMJ25mm:during_flight( context, next_pos, self_vox )
  local hit_info = physics.RayHit.hit_detect( context.pos,
                                              context.dir,
                                              VecLength( VecSub( next_pos, context.pos ) ),
                                              context.ignored )
  if hit_info.is_hit then
    local hit_pos = VecAdd( context.pos, VecScale( context.dir, hit_info.distance ) )
    MakeHole( hit_pos, 1, 0.85, 0.7 )
    SpawnParticle( hit_pos, Vec( 0, 1.0 + util.random( 1, 30 ) * 0.1, 0 ), 1.5 )
    --- @cast self.hit_snd Sound
    self.hit_snd:play( hit_pos, 0.5 )
  end
  self:draw_sprite( context.pos, next_pos )
  Bullet25mm.spwan_wakeflame( context.pos )
  return not hit_info.is_hit
end

--- @package
--- @class HE25mm : Bullet25mm
local HE25mm = lurti.core.object.class( Bullet25mm )

--- @generic T
--- @param context Context
--- @param next_pos Coord
--- @param self_vox? Handle
--- @return boolean
function HE25mm:during_flight( context, next_pos, self_vox )
  local hit_info = physics.RayHit.hit_detect( context.pos,
                                              context.dir,
                                              VecLength( VecSub( next_pos, context.pos ) ),
                                              context.ignored )
  if hit_info.is_hit then
    local hit_pos = VecAdd( context.pos, VecScale( context.dir, hit_info.distance ) )
    Explosion( hit_pos, 0.5 )
  end
  self:draw_sprite( context.pos, next_pos )
  Bullet25mm.spwan_wakeflame( context.pos )
  return not hit_info.is_hit
end

--- @package
local texture = LoadSprite( 'MOD/images/bullet25mm.png' )

return armament.Weapon:new(
  '25mm',
  0.5,
  {
    FMJ25mm:new(
      'FMJ',
      texture,
      sound.Sound:new( LoadSound( 'explosion/s0.ogg' ) )
    ),
    HE25mm:new(
      'HE',
      texture
    ),
  },
  'MOD/images/crosshair25mm.png',
  sound.LoopSound:new( LoadLoop( 'MOD/sounds/shot25mm.ogg' ) )
)
