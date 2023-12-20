local class = require("utils.class")
local button = require('components.Button')

---
-- @type stateListener
local stateListener = class(button)

---
-- Initialize the new module instance
-- @param control #string - The fully qualified name for the control this represents
function stateListener:init(control, ...)
  self.super().init(self, control)
  
  for _, func in ipairs(arg) do
    self:register(func)
  end
end

---
-- We overwrite the press function to do nothing, because we don't want to update the state from the GUI.
function stateListener:press()
end

return stateListener