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
--- @class Bullet40mm : LaunchableAmmo
--- @field sprite Handle
local Bullet40mm      = lurti.core.object.class( armament.LaunchableAmmo )

--- @param name string
--- @param sprite Handle
--- @return self
function Bullet40mm:init( name, sprite )
  lurti.core.object.init_super( Bullet40mm, self, name )
  self.sprite = sprite
  return self
end

--- @param pos Coord
--- @param dir SpaceVec
--- @param snd Sound
--- @return nil
function Bullet40mm:fire( pos, dir, snd )
  --- @type Projectile
  local prjctle = projectile_pool:pop()
  dir = VecScale( dir, 2 )
  prjctle:reset_with( self, pos, dir )
  projectile_mgr:commit( prjctle )
  snd:play( pos, 0.4 )
end

--- @generic T
--- @param context Context
--- @param next_pos Coord
--- @param self_vox? Handle
--- @return boolean
function Bullet40mm:during_flight( context, next_pos, self_vox )
  local hit_info = physics.RayHit.hit_detect( context.pos,
                                              context.dir,
                                              VecLength( VecSub( next_pos, context.pos ) ),
                                              context.ignored )
  if hit_info.is_hit then
    local hit_pos = VecAdd( context.pos, VecScale( context.dir, hit_info.distance ) )
    Explosion( hit_pos, 1.5 )
  end
  local rot = QuatLookAt( context.pos, next_pos )
  local spritepos = TransformToParentPoint( Transform( context.pos, rot ), Vec( 0, 0, -1 ) )
  rot = QuatRotateQuat( rot, QuatEuler( -90, 0, 0 ) )
  local transform = Transform( spritepos, rot )
  DrawSprite( self.sprite, transform, 0.35, 1, 1, 1, 1, 1, true, false )

  ParticleReset()
  ParticleType( 'smoke' )
  ParticleRadius( util.random( 0.1, 0.15 ), util.random( 0.03, 0.06 ) )
  SpawnParticle( context.pos, Vec( 0, 0, 0 ), 0.5 )
  return not hit_info.is_hit
end

return armament.Weapon:new(
  '40mm',
  10,
  {
    Bullet40mm:new(
      'HE',
      LoadSprite( 'MOD/images/bullet40mm.png' )
    ),
  },
  'MOD/images/crosshair40mm.png',
  sound.Sound:new( LoadSound( 'MOD/sounds/shot40mm.ogg' ) )
)
