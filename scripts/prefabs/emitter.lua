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

--- @class Water: LaunchableAmmo
local Water           = lurti.core.meta.class( armament.LaunchableAmmo )

--- @param name string
--- @param hit_snd Sound
--- @return self
function Water:init( name, hit_snd )
  lurti.core.meta.init_super( Water, self, name )
  self.hit_snd = hit_snd
  return self
end

--- @param pos Coord
--- @param dir SpaceVec
--- @param snd Sound
--- @return nil
function Water:fire( pos, dir, snd )
  --- @type Projectile
  local prjctle = projectile_pool:pop()
  dir = VecScale( dir, 1 )
  prjctle:reset_with( self, pos, dir )
  projectile_mgr:commit( prjctle )
  snd:play( pos, 0.8 )
end

--- @generic T
--- @param context Context
--- @param next_pos Coord
--- @param self_vox? Handle
--- @return boolean
function Water:during_flight( context, next_pos, self_vox )
  ParticleReset()
  ParticleType( 'smoke' )
  ParticleAlpha( 1 )
  ParticleDrag( 0.2 )
  ParticleGravity( -5, -util.random( 10, 12.5 ), 'easein' )
  ParticleFlags( 256 )
  ParticleRadius( util.random( 0.5, 0.75 ), 0, 'easeout' )
  ParticleEmissive( util.random( 0.1, 0.3 ), 0, 'easeout' )
  ParticleTile( 3 )
  local hit_info = physics.RayHit.hit_detect( context.pos,
                                              context.dir,
                                              VecLength( VecSub( next_pos, context.pos ) ),
                                              context.ignored )
  if not hit_info.is_hit then hit_info.is_hit = IsPointInWater( context.pos ) end
  if hit_info.is_hit then
    local hit_pos = VecAdd( context.pos, VecScale( context.dir, hit_info.distance ) )
    physics.spawn_shockwave( hit_pos, 4, 3, 2000, context.ignored )
    self.hit_snd:play( hit_pos, 0.7 )

    for i = 1, 90 do
      if i % 3 == 0 then
        ParticleColor( 0.7, 0.75, 1 )
      else
        ParticleColor( 0.5, 0.6, 1 )
      end
      local dir = Vec( util.random( -1, 1 ), util.random( -1, 1 ), util.random( -1, 1 ) )
      ParticleCollide( 0, 0.5 )
      ParticleSticky( 0.1 )
      SpawnParticle( hit_pos, VecScale( dir, 15 ), util.random( 4, 6 ) )
    end
  end
  for i = 1, 3 do
    if i % 3 == 0 then
      ParticleColor( 0.7, 0.75, 1 )
    else
      ParticleColor( 0.5, 0.6, 1 )
    end
    SpawnParticle( context.pos, VecScale( context.dir, 15 ), util.random( 0, 2 ) )
  end
  return not hit_info.is_hit
end

--- @package
--- @class Napalm: LaunchableAmmo
local Napalm = lurti.core.meta.class( armament.LaunchableAmmo )

--- @param name string
--- @param hit_snd Sound
--- @return self
function Napalm:init( name, hit_snd )
  lurti.core.meta.init_super( Napalm, self, name )
  self.hit_snd = hit_snd
  return self
end

--- @param pos Coord
--- @param dir SpaceVec
--- @param snd Sound
--- @return nil
function Napalm:fire( pos, dir, snd )
  --- @type Projectile
  local prjctle = projectile_pool:pop()
  dir = VecScale( dir, 1 )
  local napalm = Spawn( "<voxbox size='1 1 1' color='0.77 0.33 0.23' prop='true' material='wood'/>",
                        Transform( pos ) )
  SpawnFire( pos )
  prjctle:reset_with( self, pos, dir, 10, napalm[1] )
  projectile_mgr:commit( prjctle )
  snd:play( pos, 0.2 )
end

--- @generic T
--- @param context Context
--- @param next_pos Coord
--- @param self_vox? Handle
--- @return boolean
function Napalm:during_flight( context, next_pos, self_vox )
  ParticleReset()
  ParticleType( 'plain' )
  ParticleColor( 1, 0.6, 0.4, 1, 0.3, 0.2 )
  ParticleAlpha( 1, 0 )
  ParticleRadius( util.random( 0.25, 0.35 ), util.random( 0.35, 0.45 ) )
  ParticleGravity( 0, util.random( 0, 3 ), 'easeout' )
  ParticleDrag( 0.4 )
  ParticleEmissive( util.random( 2, 5 ), 0, 'easeout' )
  ParticleTile( 5 )
  local hit_info = physics.RayHit.hit_detect( context.pos,
                                              context.dir,
                                              VecLength( VecSub( next_pos, context.pos ) ),
                                              context.ignored )
  if hit_info.is_hit then
    local hit_pos = VecAdd( context.pos, VecScale( context.dir, hit_info.distance ) )

    for i = 1, 50 do
      local dir = Vec( util.random( -1, 1 ),
                       util.random( -1, 1 ),
                       util.random( -1, 1 ) )
      ParticleCollide( 0, 1 )
      ParticleSticky( 0.4 )
      if i % 10 == 0 then
        local randpos = Vec( util.random( -0.5, 0.5 ),
                             util.random( -0.5, 0.5 ),
                             util.random( -0.5, 0.5 ) )
        SpawnFire( VecAdd( hit_pos, randpos ) )
      end
      SpawnParticle( hit_pos, VecScale( dir, 10 ), util.random( 2, 4 ) )
    end
    SpawnFire( hit_pos )
    self.hit_snd:play( hit_pos, 0.6 )
  end
  for _ = 1, 3 do
    local dir = VecAdd( context.dir,
                        Vec( util.random( -0.3, 0.3 ),
                             util.random( -0.3, 0.3 ),
                             util.random( -0.3, 0.3 ) ) )
    SpawnParticle( context.pos, VecScale( dir, 10 ), util.random( 0, 2 ) )
  end
  --- @cast self_vox Handle
  SetBodyTransform( self_vox, Transform( context.pos, QuatLookAt( context.pos, next_pos ) ) )
  return not hit_info.is_hit
end

--- @package
--- @class Acid: LaunchableAmmo
local Acid = lurti.core.meta.class( armament.LaunchableAmmo )

--- @param name string
--- @param hit_snd Sound
--- @return self
function Acid:init( name, hit_snd )
  lurti.core.meta.init_super( Acid, self, name )
  self.hit_snd = hit_snd
  return self
end

--- @param pos Coord
--- @param dir SpaceVec
--- @param snd Sound
--- @return nil
function Acid:fire( pos, dir, snd )
  --- @type Projectile
  local prjctle = projectile_pool:pop()
  dir = VecScale( dir, 1 )
  prjctle:reset_with( self, pos, dir )
  projectile_mgr:commit( prjctle )
  snd:play( pos, 0.2 )
end

--- @generic T
--- @param context Context
--- @param next_pos Coord
--- @param self_vox? Handle
--- @return boolean
function Acid:during_flight( context, next_pos, self_vox )
  ParticleReset()
  ParticleType( 'plain' )
  ParticleColor( 0.3, 1, 0.2, 0.5, 1, 0.4 )
  ParticleAlpha( 1, 0.5 )
  ParticleRadius( util.random( 0.15, 0.2 ), 0 )
  ParticleGravity( -5, util.random( 10, 12.5 ), 'easein' )
  ParticleDrag( 0.5 )
  ParticleEmissive( util.random( 1, 3 ), 0, 'easeout' )
  ParticleTile( 1 )
  local hit_info = physics.RayHit.hit_detect( context.pos,
                                              context.dir,
                                              VecLength( VecSub( next_pos, context.pos ) ),
                                              context.ignored )
  if hit_info.is_hit then
    local hit_pos = VecAdd( context.pos, VecScale( context.dir, hit_info.distance ) )
    self.hit_snd:play( hit_pos, 0.6 )

    for _ = 1, 70 do
      local dir = Vec( util.random( -1, 1 ), util.random( -1, 1 ), util.random( -1, 1 ) )

      ParticleCollide( 0, 1 )
      ParticleSticky( 0.3 )
      SpawnParticle( hit_pos, VecScale( dir, 10 ), util.random( 2, 4 ) )
      local randpos = Vec( util.random( -1, 1 ), 0, util.random( -1, 1 ) )
      MakeHole( VecAdd( hit_pos, randpos ),
                util.random( 0.35, 0.45 ),
                util.random( 0.25, 0.35 ),
                util.random( 0.15, 0.25 ),
                true )
    end
  end
  for _ = 1, 3 do
    local dir = VecAdd( context.dir,
                        Vec( util.random( -0.2, 0.2 ),
                             util.random( -0.2, 0.2 ),
                             util.random( -0.2, 0.2 ) ) )
    SpawnParticle( context.pos, VecScale( dir, 10 ), util.random( 0, 2 ) )
  end
  return not hit_info.is_hit
end

return armament.Weapon:new(
  'Emitter',
  1,
  {
    Water:new(
      'Water',
      sound.LoopSound:new( LoadLoop( 'MOD/sounds/hit_water.ogg' ) )
    ),
    Napalm:new(
      'Napalm',
      sound.Sound:new( LoadSound( 'MOD/sounds/hit_fire_acid.ogg' ) )
    ),
    Acid:new(
      'Acid',
      sound.LoopSound:new( LoadLoop( 'MOD/sounds/hit_fire_acid.ogg' ) )
    ),
  },
  'MOD/images/crosshair_emitter.png',
  sound.LoopSound:new( LoadLoop( 'MOD/sounds/shot_emitter.ogg' ) )
)
