--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti = require( 'libs.lurti' )
local fog = {}

--- @class FogParams : Object
--- @field private start Param
--- @field private ending Param
--- @field private amount Param
--- @field private exp Param
fog.FogParams = lurti.core.meta.class()

--- @param start Param
--- @param ending Param
--- @param amount Param
--- @param exp Param
--- @return self
function fog.FogParams:init( start, ending, amount, exp )
  lurti.core.meta.init_super( fog.FogParams, self )
  self.start = start
  self.ending = ending
  self.amount = amount
  self.exp = exp
  return self
end

--- @return FogParams
function fog.FogParams.from_game()
  local start, ending, amount, exp = GetEnvironmentProperty( 'fogParams' )
  return fog.FogParams:new( start, ending, amount, exp )
end

--- Apply the current parameters to the game.
--- @return nil
function fog.FogParams:apply()
  SetEnvironmentProperty( 'fogParams', self.start, self.ending, self.amount, self.exp )
end

--- @class FogHandler : Object
--- @field game FogParams
--- @field custom FogParams
--- @field is_dirty boolean Indicate whether the fog effect has been updated.
fog.FogHandler = lurti.core.meta.class()

--- @param custom FogParams
--- @return self
function fog.FogHandler:init( custom )
  lurti.core.meta.init_super( fog.FogHandler, self )
  self.game = fog.FogParams.from_game()
  self.custom = custom
  self.is_dirty = false
  return self
end

return fog
