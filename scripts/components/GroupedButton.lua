local class = require('utils.class')
local button = require('components.Button')

---
-- @module groupedButton
local GroupedButton = {}

---
-- @type groupedButton
-- 
local groupedButton = class(button)

local onIndividualStateChange = function (button)
  if(button.state == 1) then
    gre.set_value(button.control .. ".alpha0", 0)
    gre.set_value(button.control .. ".alpha1", 255)
  else
    gre.set_value(button.control .. ".alpha0", 255)
    gre.set_value(button.control .. ".alpha1", 0)
  end
end

local onStateChange = function(self)
  for i, button in ipairs(self.buttons) do
    if self.state == i - 1 then
      button.state = 1
      onIndividualStateChange(button)
    else
      button.state = 0
      onIndividualStateChange(button)
    end
  end
  self.update_event_callback(self.buttonID, self.state)
end

---
-- @param buttonID #string name of the button used to identify it.
-- @param control gre#control path to the control
function groupedButton:init(buttonID, ...)
  self.callbacks = {}
  self.buttonID = buttonID
  self.update_event_callback = arg[table.maxn(arg)]
  self.buttons = {}
  for i, control in ipairs(arg) do
    if i < table.maxn(arg) then
      local button = {}
      button.control = control
      button.state = 0
      self.buttons[i] = button
    end
  end
  self:register(onStateChange)
end

---
--- @param gre#context mapargs
function groupedButton:press(mapargs)
  for i, button in ipairs(self.buttons) do
    if button.control == mapargs.context_control then
     self:set_state(i - 1)
     break
    end
  end
end

return groupedButton
