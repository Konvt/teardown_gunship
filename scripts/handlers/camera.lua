--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti = require( 'libs.lurti' )
local camera = {}

--- @class ZoomHandler : Object
--- @field minimum number
--- @field maximum number
--- @field current number
camera.ZoomHandler = lurti.core.meta.class()

--- @param minimum number
--- @param maximum number
--- @return self
function camera.ZoomHandler:init( minimum, maximum )
  lurti.core.meta.init_super( camera.ZoomHandler, self )
  self.minimum = minimum
  self.maximum = maximum
  self.current = (minimum + maximum) / 2
  return self
end

--- @param delta number
--- @return self
function camera.ZoomHandler:zoom( delta )
  self.current = math.min( math.max( self.current - delta, self.minimum ), self.maximum )
  return self
end

--- @return number
function camera.ZoomHandler:level()
  return self.current
end

--- @class CameraHandler : ZoomHandler
--- @field aim_point Coord | nil
--- @field is_airborne boolean
camera.CameraHandler = lurti.core.meta.class( camera.ZoomHandler )

--- @param min_zoom number
--- @param max_zoom number
--- @return self
function camera.CameraHandler:init( min_zoom, max_zoom )
  lurti.core.meta.init_super( camera.CameraHandler, self, min_zoom, max_zoom )
  self.aim_point = nil
  self.is_airborne = false
  return self
end

--- Return the information of the cam_loc aiming point.
--- @param cam_pos Pose The position of the game object used as a camera.
--- @return TVec target_position
--- @return boolean is_hit
--- @return number target_distance
function camera.CameraHandler.look_at( cam_pos )
  local fwd_pos = TransformToParentPoint( cam_pos, Vec( 0, 0, -300 ) )
  local direction = VecSub( fwd_pos, cam_pos.pos )
  local distance = VecLength( direction )
  direction = VecNormalize( direction )
  local hit, hit_dist = QueryRaycast( cam_pos.pos, direction, distance )
  if hit then
    fwd_pos = TransformToParentPoint( cam_pos, Vec( 0, 0, -hit_dist ) )
    distance = hit_dist
  end
  return fwd_pos, hit, distance
end

--- @return TVec target_position
--- @return boolean is_hit
--- @return number target_distance
function camera.CameraHandler.player_look_at()
  return camera.CameraHandler.look_at( GetCameraTransform() )
end

--- @param aircraft PlaneHandler
--- @return nil
function camera.CameraHandler:switch_to( aircraft )
  local mouse_wheel = InputValue( 'mousewheel' )
  if mouse_wheel ~= 0 then self:zoom( mouse_wheel / 2 ) end

  local mouse_dx, mouse_dy = InputValue( 'mousedx' ), InputValue( 'mousedy' )
  local rotdiv = 200 / self.current

  local target = self.aim_point
  --- @cast target Coord
  local cam_rot = QuatLookAt( aircraft.barrel.pos, target )
  cam_rot = QuatRotateQuat( cam_rot, QuatEuler( -mouse_dy / rotdiv, -mouse_dx / rotdiv, 0 ) )
  aircraft.barrel.rot = cam_rot

  local new_trans = Transform( aircraft.barrel.pos, cam_rot )
  SetCameraTransform( new_trans, self.current * 10 )
  SetPlayerTransform( GetPlayerTransform() )
  aircraft.snd:play( GetCameraTransform().pos, 0.5 )
end

return camera
