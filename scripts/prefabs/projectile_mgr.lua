--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti = require( 'libs.lurti' )
local prjctle_pool = require( 'scripts.prefabs.projectile_pool' )

--- @class ProjectileMgr : Object
--- @field inflight Projectile[]
local ProjectileMgr = lurti.core.object.class()

--- @return self
function ProjectileMgr:init()
  lurti.core.object.init_super( ProjectileMgr, self )
  --- @type Projectile[]
  self.inflight = {}
  return self
end

--- @param prjctle Projectile
--- @return self
function ProjectileMgr:commit( prjctle )
  self.inflight[#self.inflight+1] = prjctle
  return self
end

--- @param dt DeltaTime
--- @param ignored? Handle[]
--- @return self
function ProjectileMgr:update( dt, ignored )
  ignored = ignored or {}
  local tail = #ignored
  local prjctle_dead = false
  local cursor, num_prjctle = 1, #self.inflight
  while cursor <= num_prjctle do
    local prjctle = self.inflight[cursor]
    --- @cast prjctle Projectile
    if prjctle.alive then
      ignored[tail + 1] = prjctle.vox_body
      prjctle:during_flight( dt, ignored ) -- has side effect
      num_prjctle = #self.inflight
    end
    prjctle.lifetime:update( dt )
    if not prjctle.alive or prjctle.lifetime:expired() then
      if prjctle.vox_body ~= nil then Delete( prjctle.vox_body ) end
      prjctle_dead = true
    end
    cursor = cursor + 1
  end
  if prjctle_dead then
    for i = #self.inflight, 1, -1 do
      if not self.inflight[i].alive or self.inflight[i].lifetime:expired() then
        prjctle_pool:push( table.remove( self.inflight, i ) )
      end
    end
  end
  ignored[tail + 1] = nil
  return self
end

return ProjectileMgr:new()
