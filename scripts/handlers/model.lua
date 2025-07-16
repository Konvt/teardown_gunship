--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti = require( 'libs.lurti' )
local timer = require( 'scripts.types.timer' )
local model = {}

--- @package
--- @class VoxModel : Object
--- @field subject [Handle, Pose]
--- @field antenna [Handle, Pose]
--- @field aircraft Handle
--- @field blink [Handle, Pose]
model.VoxModel = lurti.core.meta.class()

--- @param radio_shp Handle
--- @param antenna_shp Handle
--- @param plane_shp Handle
--- @param blink_shp Handle
--- @return self
function model.VoxModel:init( radio_shp, antenna_shp, plane_shp, blink_shp )
  lurti.core.meta.init_super( model.VoxModel, self )
  self.subject = { radio_shp, GetShapeLocalTransform( radio_shp ) }
  self.antenna = { antenna_shp, GetShapeLocalTransform( antenna_shp ) }
  self.aircraft = plane_shp
  self.blink = { blink_shp, GetShapeLocalTransform( blink_shp ) }
  return self
end

--- @class ModelHandler : Object
--- @field tool_model VoxModel
--- @field body Handle
--- @field snd Sound
--- @field startup_timer ElapsedTimer
--- @field activated boolean
model.ModelHandler = lurti.core.meta.class()

--- @param snd Sound
--- @param boot_delay DeltaTime
--- @return self
function model.ModelHandler:init( snd, boot_delay )
  lurti.core.meta.init_super( model.ModelHandler, self )
  --- @type VoxModel
  self.tool_model = model.VoxModel()
  self.body = 0
  self.snd = snd
  self.startup_timer = timer.ElapsedTimer:new( boot_delay ):unwrap()
  self.activated = false
  return self
end

--- @param dt DeltaTime
--- @return self
function model.ModelHandler:render_radio( dt )
  local current_body = GetToolBody()
  if current_body ~= 0 and self.body ~= current_body then
    self.body = current_body

    --- @type Handle[]
    local shapes = GetBodyShapes( current_body )
    local radio_shp, antenna_shp, plane_shp, blink_shp = shapes[1], shapes[2], shapes[3], shapes[4]
    --- @cast radio_shp Handle
    --- @cast antenna_shp Handle
    --- @cast plane_shp Handle
    --- @cast blink_shp Handle

    self.tool_model:init( radio_shp, antenna_shp, plane_shp, blink_shp )
  elseif current_body == 0 then
    return self
  end

  if not self.activated then
    self.startup_timer:update( dt * 2 )
    if self.startup_timer:expired() then
      self.snd:play( GetCameraTransform().pos, 0.4 )
      self.activated = true
    end
  end

  if self.activated then
    SetShapeEmissiveScale( self.tool_model.subject[1], 0.5 )
  else
    SetShapeEmissiveScale( self.tool_model.subject[1], 0 )
  end
  if InputDown( 'lmb' ) then
    SetShapeEmissiveScale( self.tool_model.blink[1], 5 )
  else
    SetShapeEmissiveScale( self.tool_model.blink[1], 0 )
  end

  local rt_copy = TransformCopy( self.tool_model.subject[2] )
  rt_copy.rot = QuatRotateQuat( rt_copy.rot, QuatEuler( 0, 0, -15 ) )
  SetShapeLocalTransform( self.tool_model.subject[1], rt_copy )

  local bt_copy = TransformCopy( self.tool_model.blink[2] )
  bt_copy.rot = QuatRotateQuat( bt_copy.rot, QuatEuler( 0, 0, -15 ) )
  SetShapeLocalTransform( self.tool_model.blink[1], bt_copy )

  local at_copy = TransformCopy( self.tool_model.antenna[2] )
  at_copy.pos = VecAdd( at_copy.pos, Vec( 0, self.startup_timer:present() * 0.4, 0 ) )
  at_copy.rot = QuatRotateQuat( at_copy.rot, QuatEuler( 0, 0, -15 ) )
  SetShapeLocalTransform( self.tool_model.antenna[1], at_copy )

  return self
end

--- @param position Pose
--- @return self
function model.ModelHandler:render_plane( position )
  -- if not self.tool_model then return self end
  SetShapeLocalTransform( self.tool_model.aircraft,
                          TransformToLocalTransform(
                            GetBodyTransform( GetToolBody() ), position ) )
  return self
end

return model
