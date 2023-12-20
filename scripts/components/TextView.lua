local class = require("utils.class")
local button = require('components.Button')

---
-- @type textView
local textView = class(button)

local onStateChange = function (self)
  gre.set_value(self.control .. ".text", tostring(self.state))
end

---
-- Initialize the new module instance
-- @param control #string - The fully qualified name for the control this represents
function textView:init(control, ...)
  self.super().init(self, control)
  self:register(onStateChange)
  
  for _, func in ipairs(arg) do
    self:register(func)
  end
end

---
-- We overwrite the press function to do nothing, because we don't want to update the state from the GUI.
function textView:press()
end

return textView