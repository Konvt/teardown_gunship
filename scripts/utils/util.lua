--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti = require( 'libs.lurti' )
local util = {}

--- @param min number
--- @param max number
function util.random( min, max )
  return min + (max - min) * math.random()
end

--- Generate a random vector around axis with angle (radians) in [min_angle, max_angle]
--- @param axis SpaceVec
--- @param max_angle? number
--- @param min_angle? number
--- @param mode? string 'sphere' | 'angle' | 'double_cone' (default: 'sphere')
--- @return Result<SpaceVec, string>
--- @nodiscard
function util.rd_axis_dir( axis, max_angle, min_angle, mode )
  max_angle = max_angle or math.pi / 4
  min_angle = min_angle or 0

  --- @type number
  local x, y, z
  local theta = util.random( 0, 2 * math.pi )

  if mode == nil or mode == 'sphere' then
    local cos_min = math.cos( min_angle )
    local cos_max = math.cos( max_angle )
    local cos_phi = util.random( cos_max, cos_min )
    local phi = math.acos( cos_phi )

    x = math.sin( phi ) * math.cos( theta )
    y = math.sin( phi ) * math.sin( theta )
    z = math.cos( phi )
  elseif mode == 'angle' then
    local phi = util.random( min_angle, max_angle )
    x = math.sin( phi ) * math.cos( theta )
    y = math.sin( phi ) * math.sin( theta )
    z = math.cos( phi )
  elseif mode == 'double_cone' then
    local choice = math.random()
    local phi
    if choice < 0.5 then
      phi = util.random( min_angle, max_angle )
    else
      phi = math.pi - max_angle + util.random( 0, max_angle - min_angle )
    end

    x = math.sin( phi ) * math.cos( theta )
    y = math.sin( phi ) * math.sin( theta )
    z = math.cos( phi )
  else
    return lurti.core.result.Err( 'unknown mode: ' .. tostring( mode ) )
  end

  local up = Vec( 0, 1, 0 )
  if math.abs( VecDot( axis, up ) ) > 0.99 then
    up = Vec( 1, 0, 0 )
  end

  local axis_x = VecNormalize( VecCross( up, axis ) )
  local axis_y = VecCross( axis, axis_x )

  local dir = VecAdd(
    VecAdd( VecScale( axis_x, x ), VecScale( axis_y, y ) ),
    VecScale( axis, z )
  )

  return lurti.core.result.Ok( dir )
end

--- @generic T
--- @param ele T
--- @param array T[]
--- @param ignored? T[]
--- @return boolean
function util.existed_in( ele, array, ignored )
  local ignored_set = {}
  if ignored then
    for i = 1, #ignored do
      ignored_set[ignored[i]] = true
    end
  end

  for i = 1, #array do
    if ele == array[i] and not ignored_set[ele] then
      return true
    end
  end
  return false
end

--- @param left string
--- @param right string
--- @param total_width integer
function util.align_lr_fill( left, right, total_width )
  local space_count = total_width - #left - #right
  if space_count < 0 then space_count = 0 end
  return left .. string.rep( ' ', space_count ) .. right
end

return util
