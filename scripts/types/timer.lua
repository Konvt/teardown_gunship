--- Copyright (c) 2025 Konvt
--- This file is licensed under the Mozilla Public License 2.0.
--- See the LICENSE file in the project root for license terms.
local lurti = require( 'libs.lurti' )
local timer = {}

--- @class TrackedTimer : Object
--- @field protected duration DeltaTime
--- @field protected current DeltaTime
--- @field protected is_active boolean
timer.TrackedTimer = lurti.core.object.class( nil, lurti.core.abc.ABCMeta )

--- @param duration DeltaTime
--- @return self
function timer.TrackedTimer:init( duration )
  lurti.core.object.init_super( timer.TrackedTimer, self )
  self.duration = duration
  self.is_active = false
  return self
end

--- @param dt DeltaTime
--- @return nil
function timer.TrackedTimer:update( dt )
  lurti.core.panic.raise( lurti.core.panic.KIND.MISSING_OVERRIDE )
end

--- @return nil
function timer.TrackedTimer:reset()
  lurti.core.panic.raise( lurti.core.panic.KIND.MISSING_OVERRIDE )
end

--- @return boolean
function timer.TrackedTimer:active()
  return self.is_active
end

--- @return boolean
function timer.TrackedTimer:expired()
  lurti.core.panic.raise( lurti.core.panic.KIND.MISSING_OVERRIDE )
  return false
end

--- @return DeltaTime
function timer.TrackedTimer:present()
  return self.current
end

--- @return DeltaTime
function timer.TrackedTimer:period()
  return self.duration
end

lurti.core.abc.abstract( timer.TrackedTimer, { 'update', 'reset' } )

--- @class CountdownTimer : TrackedTimer
timer.CountdownTimer = lurti.core.object.class( timer.TrackedTimer )

--- @param duration DeltaTime
--- @return self
function timer.CountdownTimer:init( duration )
  lurti.core.object.init_super( timer.CountdownTimer, self, duration )
  self.current = duration
  return self
end

--- @param duration DeltaTime
--- @return Result<self, string>
--- @nodiscard
function timer.CountdownTimer:new( duration )
  if duration < 0 then
    return lurti.core.result.Err( 'duration cannot be less than zero' )
  end
  return lurti.core.result.Ok( self():init( duration ) )
end

--- @param dt DeltaTime
--- @return nil
function timer.CountdownTimer:update( dt )
  self.is_active = true
  self.current = math.max( self.current - dt, 0 )
end

--- @return boolean
function timer.CountdownTimer:expired()
  return self.current <= 0
end

--- @return nil
function timer.CountdownTimer:reset()
  self.current = self.duration
  self.is_active = false
end

--- @class ElapsedTimer : TrackedTimer
timer.ElapsedTimer = lurti.core.object.class( timer.TrackedTimer )

--- @param duration DeltaTime
--- @return self
function timer.ElapsedTimer:init( duration )
  lurti.core.object.init_super( timer.ElapsedTimer, self, duration )
  --- @type number
  self.current = 0
  return self
end

--- @param duration DeltaTime
--- @return Result<self, string>
--- @nodiscard
function timer.ElapsedTimer:new( duration )
  if duration < 0 then
    return lurti.core.result.Err( 'duration cannot be less than zero' )
  end
  return lurti.core.result.Ok( self():init( duration ) )
end

--- @param dt DeltaTime
--- @return nil
function timer.ElapsedTimer:update( dt )
  self.is_active = true
  self.current = math.min( self.current + dt, self.duration )
end

--- @return boolean
function timer.ElapsedTimer:expired()
  return self.current >= self.duration
end

--- @return nil
function timer.ElapsedTimer:reset()
  self.current = 0
  self.is_active = false
end

return timer
