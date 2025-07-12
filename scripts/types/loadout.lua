--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti   = require( 'libs.lurti' )
local timer   = require( 'scripts.types.timer' )
local loadout = {}

--- @class Slot : Object
--- @field weapon Weapon
--- @field private bullet integer
--- @field cooldown CountdownTimer
loadout.Slot  = lurti.core.object.class()

--- @param weapon Weapon
--- @param max_cd? DeltaTime
--- @return self
function loadout.Slot:init( weapon, max_cd )
  lurti.core.object.init_super( loadout.Slot, self )
  self.weapon   = weapon
  self.bullet   = 1
  self.cooldown = timer.CountdownTimer:new( max_cd or 0 ):unwrap()
  return self
end

--- @return self
function loadout.Slot:next_ammo()
  self.bullet = (self.bullet % #self.weapon.magazine) + 1
  return self
end

--- @return LaunchableAmmo | nil
function loadout.Slot:ammo()
  return self.weapon.magazine[self.bullet]
end

--- @class Loadout : Object
--- @field slot Slot[]
--- @field switch_sound Handle
--- @field private equipped integer
loadout.Loadout = lurti.core.object.class()

--- @param switch_sound Handle
--- @param slots Slot[]
--- @return self
function loadout.Loadout:init( switch_sound, slots )
  lurti.core.object.init_super( loadout.Loadout, self )
  self.switch_sound = switch_sound
  self.slot         = slots
  self.equipped     = 1
  return self
end

--- @return self
function loadout.Loadout:next_equipment()
  self.equipped = (self.equipped % #self.slot) + 1
  return self
end

--- @return Slot | nil
function loadout.Loadout:equipment()
  return self.slot[self.equipped]
end

return loadout
