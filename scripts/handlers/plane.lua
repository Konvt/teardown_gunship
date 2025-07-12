--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti = require( 'libs.lurti' )
local timer = require( 'scripts.types.timer' )
local plane = {}

--- @class PlaneHandler : Object
--- @field itself Pose
--- @field barrel Pose
--- @field snd Sound
--- @field firelight_timer CountdownTimer
plane.PlaneHandler = lurti.core.object.class()

--- @param pose Pose
--- @param snd Sound
--- @return self
function plane.PlaneHandler:init( pose, snd )
  lurti.core.object.init_super( plane.PlaneHandler, self )
  self.itself = pose
  self.barrel = Transform()
  self.barrel.rot = Quat()
  self.snd = snd
  self.firelight_timer = timer.CountdownTimer:new( 0.05 ):unwrap()
  return self
end

--- @return nil
function plane.PlaneHandler:update()
  local fwd_pos = TransformToParentPoint( self.itself, Vec( -0.15, 0, 0 ) )
  local rotation = QuatRotateQuat( self.itself.rot, QuatEuler( 0, 0, 0.1 ) )
  self.itself.pos = fwd_pos
  self.itself.rot = rotation
  self.barrel.pos = TransformToParentPoint( self.itself, Vec( 2.5, 4.5, 0 ) )
end

return plane
