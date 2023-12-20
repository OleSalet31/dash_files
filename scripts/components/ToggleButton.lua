local class = require('utils.class')
local button = require('components.Button')

---
-- @type toggleButton
-- @field gredom#control control
-- @field #boolean state
-- @field #function update_state_callback
local toggleButton = class(button)

-- This is a custom function that is called when the active state changes. Here we change the image.
local onStateChange = function (self)
  
  if nil ~= gre.get_value(self.control .. ".alpha" .. self.state) then
    
    local i = 0
    while nil ~= gre.get_value(self.control .. ".alpha" .. i) do
      if self.state == i then
        gre.set_value(self.control .. ".alpha" .. i, 255)
      else 
        gre.set_value(self.control .. ".alpha" .. i, 0)
      end
      i = i + 1
    end
  else
    self:set_state(0)
    return
  end
  
  if self.update_state_callback ~= nil then
    self.update_state_callback(self.buttonID, self.state)
  end
end

---
-- Initialize the new module instance
-- @param control #string - The fully qualified name for the control this represents
-- @param update_state_callback #function - Function that is executed when the state of this button is updated
-- 
function toggleButton:init(control, update_state_callback)
  self.super().init(self, control)
  self:register(onStateChange)
  
  if update_state_callback ~= nil then
    self.update_state_callback = update_state_callback
  end
end

function toggleButton:press()
  self:set_state(self.state + 1)
end

return toggleButton