local class = require('utils.class')
local button = require('components.Button')

---
-- @module volumeButton
local VolumeButton = {}

---
-- @type volumeButton
-- @field #string buttonID
-- @field gredom#control control_min
-- @field gredom#control control_plus
-- @field #function update_state_callback
local volumeButton = class(button)

local onStateChange = function (self)
  
  -- Here we check if the value has exceeded it's min or max values. 
  -- if loop is true, then we `loop` around if we exceed the max. 
  -- If higher then max, we go to min and vice versa.
  --
  -- Otherwise we stay at the max or min value.
  
  if self.loop == false then
    if self.state > self.max then
      self.state = self.max
    elseif self.state < self.min then
      self.state = self.min
    end
  else
    if self.state > self.max then
      self.state = self.min
    elseif self.state < self.min then
      self.state = self.max
    end
  end

  if self.update_state_callback ~= nil then
    self.update_state_callback(self.buttonID, self.state)
  end
end

---
-- Initialize the new module instance
-- @param control #string - The fully qualified name for the control this represents
-- 
function volumeButton:init(buttonID, control_min, control_plus, update_state_callback, init, min, max, loop)
  self.callbacks = {}
  self.buttonID = buttonID
  self.control_min = control_min
  self.control_plus = control_plus
  
  self.timeout = {}
  self.timeout_time = 200
  
  self.min = 0
  self.state = 0
  self.max = 10
  
  if min ~= nil then
    self.min = min
  end
  if init ~= nil then
    self.state = init
  end
  if max ~= nil then
    self.max = max
  end
  if loop ~= nil then
    self.loop = loop
  else
    self.loop = false
  end
  
  self.update_state_callback = update_state_callback
  self:register(onStateChange)
end

local function press_and_hold_cb(self, value)
  self:set_state(self.state + value)
  self.timeout = gre.timer_set_timeout(function() press_and_hold_cb(self, value) end, math.max(80, self.timeout_time))
  self.timeout_time = self.timeout_time - 20
end
---
--- @param gre#context mapargs
function volumeButton:press(mapargs)
  gre.set_value(mapargs.context_control .. ".alpha0", 0)
  gre.set_value(mapargs.context_control .. ".alpha1", 255)
  if mapargs.context_control == self.control_min then
    self:set_state(self.state - 1)
    self.timeout = gre.timer_set_timeout(function() press_and_hold_cb(self, -1) end, 1000)
  elseif mapargs.context_control == self.control_plus then
    self:set_state(self.state + 1)
    self.timeout = gre.timer_set_timeout(function() press_and_hold_cb(self, 1) end, 1000)
  end
end

---
--- @param gre#context mapargs
function volumeButton:release(mapargs)
  
  gre.timer_clear_timeout(self.timeout)
  self.timeout_time = 200

  gre.set_value(self.control_min .. ".alpha0", 255)
  gre.set_value(self.control_min .. ".alpha1", 0)
  
  gre.set_value(self.control_plus .. ".alpha0", 255)
  gre.set_value(self.control_plus .. ".alpha1", 0)
end

return volumeButton