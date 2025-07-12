--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti = require( 'libs.lurti' )
local projectile = require( 'scripts.types.projectile' )

return lurti.collections.pool.ObjectPool:new_with(
  projectile.Projectile:new(),
  1000
)
