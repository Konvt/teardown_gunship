--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti = require( 'libs.lurti' )
local armament = {}

--- @class Ammo : Object
armament.Ammo = lurti.core.meta.class( nil, lurti.core.abc.ABCMeta )

--- @param name string
--- @return self
function armament.Ammo:init( name )
  lurti.core.meta.init_super( armament.Ammo, self )
  self.name = name
  return self
end

--- @class Context
--- @field dt DeltaTime
--- @field pos Coord Current position.
--- @field dir SpaceVec Current direction, is an unit vector.
--- @field ignored Handle[] Ignored object when calculating physical effects.

--- @generic T
--- @param dt DeltaTime
--- @param velocity SpaceVec
--- @return SpaceVec
function armament.Ammo:predict_velocity( dt, velocity )
  return velocity
end

--- @generic T
--- @param context Context
--- @param next_pos Coord
--- @param self_vox? Handle
--- @return boolean is_alive Indicates whether the current shells have died out
function armament.Ammo:during_flight( context, next_pos, self_vox )
  lurti.core.panic.raise( lurti.core.panic.KIND.MISSING_OVERRIDE )
  return false
end

lurti.core.abc.abstract( armament.Ammo, 'during_flight' )

--- @class LaunchableAmmo : Ammo
armament.LaunchableAmmo = lurti.core.meta.class( armament.Ammo )

--- @param name string
--- @return self
function armament.LaunchableAmmo:init( name )
  lurti.core.meta.init_super( armament.LaunchableAmmo, self, name )
  return self
end

--- @param pos Coord Source position.
--- @param dir SpaceVec Target direction, should be an unit vector.
--- @param snd Sound Firing sound effect
--- @return nil
function armament.LaunchableAmmo:fire( pos, dir, snd )
  lurti.core.panic.raise( lurti.core.panic.KIND.MISSING_OVERRIDE )
end

lurti.core.abc.abstract( armament.LaunchableAmmo, 'fire' )

--- @class Weapon : Object
--- @field magazine Ammo[]
--- @field interval_factor number
--- @field crosshair_path string
--- @field shot_snd Sound
armament.Weapon = lurti.core.meta.class()

--- @param name string
--- @param interval_factor number
--- @param magazine Ammo[]
--- @param crosshair_path string
--- @param shot_snd Sound
--- @return self
function armament.Weapon:init( name, interval_factor, magazine,
                               crosshair_path, shot_snd )
  lurti.core.meta.init_super( armament.Weapon, self )
  self.name            = name
  self.interval_factor = interval_factor
  self.magazine        = magazine
  self.crosshair_path  = crosshair_path
  self.shot_snd        = shot_snd
  return self
end

return armament
