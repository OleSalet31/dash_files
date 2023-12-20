local class = require("utils.class")
local button = require('components.Button')

---
-- @type rotaryButton
local rotaryButton = class(button)

local onStateChange = function (self)
  gre.set_value(self.control .. ".text", tostring(self.state))
end

---
-- Initialize the new module instance
-- @param control #string - The fully qualified name for the control this represents
function rotaryButton:init(control, ...)
  self.super().init(self, control)
  self.pressed = false
  self:register(onStateChange)
  
  for _, func in ipairs(arg) do
    self:register(func)
  end
end

---
-- We overwrite the press function to do nothing, because we don't want to update the state from the GUI.
function rotaryButton:press()
end

function rotaryButton:calculatePosition(press_x, press_y)
  local dk_data = {}
  local mid_x, mid_y
  local ctrl_x, ctrl_y
  local calc_x,calc_y
  local radians, degrees
  
  dk_data = gre.get_data(self.control..".grd_width",self.control..".grd_height",self.control..".grd_x",self.control..".grd_y",self.control..".angle")
  mid_x = dk_data[self.control..".grd_width"] / 2
  mid_y = dk_data[self.control..".grd_height"] / 2
  ctrl_x = dk_data[self.control..".grd_x"]
  ctrl_y = dk_data[self.control..".grd_y"]

  calc_x = press_x - mid_x - ctrl_x
  calc_y = press_y - mid_y - ctrl_y
  
  radians = math.atan2(calc_y,  calc_x)
  degrees = math.deg(radians)

  -- rotate quadrant to align control rotation degrees
  if(degrees < 0)then
    --on the top portion of the circle
    degrees = 90 - math.abs(degrees)
    if(degrees < 0)then
      degrees = 360 - math.abs(degrees)  
    end  
  else
    degrees = 90 + math.abs(degrees)
  end

  -- apply start and end stops
  --[[if(degrees > 54 and degrees < 90)then
    degrees = 54
  elseif(degrees > 90 and degrees < 126)then
    degrees = 126
  end--]]
  
  print("press_x:" ..press_x .." press_y:" ..press_y )
  print("ctrl_x:" ..ctrl_x .." ctrl_y:" ..ctrl_y )
  print("calc_x:" ..calc_x .." calc_y:" ..calc_y )
  print("x:" ..press_x - mid_x.." y:" ..press_y - mid_y .. " deg:"..degrees)
  
  local data = {}
  data["controls_layer.degrees.text"] = string.format("%3.1fº",degrees)
  data[self.control..".angle"] = degrees
  gre.set_data(data) 
end

--Checks if motion is on current slider if so, calculates slider position
function rotaryButton:CBKnobMotion(mapargs)  
  if self.pressed == false then
    return
  else 
    self:calculatePosition(mapargs.context_event_data.x, mapargs.context_event_data.y)
  end
end

function rotaryButton:CBKnobPress(mapargs)
  self.pressed = true
  self:calculatePosition(mapargs.context_event_data.x, mapargs.context_event_data.y)
end

--When the slider is released set the active slider to nil
function rotaryButton:CBKnobRelease(mapargs)
  self.pressed = false
end

return rotaryButton