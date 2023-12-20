class = require("utils.class")

---
-- @module button
--
local Button = {}

---
-- @type button
-- @field gredom#control control
-- @field #boolean state
-- @field #table callbacks
local button = class()

---
-- Helper function which sets the button ID, as the control name
local function setButtonID(control)
  local t={}
  for str in string.gmatch(control, "([^.]+)") do
    table.insert(t, str)
  end
  return t[table.maxn(t)]
end

---
-- Initialize the new module instance
-- @param control #string - The fully qualified name for the control this represents
function button:init(control)
  self.control = control
  self.buttonID = setButtonID(self.control)
  self.state = 0
  self.callbacks = {}
end
 
---
-- Call when the control receives a press event
function button:press()
  if(self.state == 1) then
    self:set_state(0)
  else
    self:set_state(1)
  end
end
 
---
-- Sets the buttons state
-- @param state #any - can be boolean, array of booleans or anything else that defines the state of the button.
function button:set_state(state)
  self.state = state
  self:notify(self.state)
end
 
---
-- Gets the buttons state
-- @return #any
function button:get_state()
  return self.state
end
 
---
-- Gets the buttons ID
-- @return #any
function button:get_buttonID()
  local t={}
  for str in string.gmatch(self.control, "([^.]+)") do
    table.insert(t, str)
  end
  return t[table.maxn(t)]
end
 
---
-- Registers a callback function for a state change
-- @param callback #function - The callback to register
-- @return #boolean - True if callback successfully registered
function button:register(callback)
  table.insert(self.callbacks, callback)
  return true
end
 
---
-- Removes a callback function from the list of callbacks
-- @param callback #function - The callback to remove
-- @return #boolean - True if callback successfully removed
function button:unregister(callback)
  for i,v in ipairs(self.callbacks) do
    if (v == callback) then
      table.remove(self.callbacks,i)
        return true
    end
  end
  return false
end
 
---
-- Notifies all callbacks, the callback can use the self to get it's variables.
function button:notify()
  for _,v in ipairs(self.callbacks) do
    v(self)
  end
end
 
return button