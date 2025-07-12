--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti = require( 'libs.lurti' )
local sound = {}

--- @class Sound : Object
--- @field handle Handle
sound.Sound = lurti.core.object.class()

--- @param handle Handle
--- @return self
function sound.Sound:init( handle )
  lurti.core.object.init_super( sound.Sound, self )
  self.handle = handle
  return self
end

--- @param pos? Coord
--- @param volume? number
function sound.Sound:play( pos, volume )
  PlaySound( self.handle, pos, volume )
end

--- @class LoopSound : Sound
--- @field handle Handle
sound.LoopSound = lurti.core.object.class( sound.Sound )

--- @param handle Handle
--- @return self
function sound.LoopSound:init( handle )
  lurti.core.object.init_super( sound.LoopSound, self, handle )
  return self
end

--- @param pos? Coord
--- @param volume? number
function sound.LoopSound:play( pos, volume )
  PlayLoop( self.handle, pos, volume )
end

return sound
