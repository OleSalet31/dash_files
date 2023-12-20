local class = require('utils.class')
local button = require('components.Button')

---
-- @module sliderButton
local SliderButton = {}

---
-- @type sliderButton
local sliderButton = class(button)

local updateSliderLevel = function(self)
  local maxY = gre.get_value(self.control .. "._Ellipse____Pixellaag.grd_height") - gre.get_value(self.control .. "._Ellipse____Pixellaag.height")
  gre.set_value(self.control .. "._Ellipse____Pixellaag.y", (self.state*maxY/100))
end

---
-- Initialize the new module instance
-- @param control #string - The fully qualified name for the control this represents
--
function sliderButton:init(buttonID, control)
  self.buttonID = buttonID
  self.callbacks = {}
  self.control = control
  self.pressed = false
  self.tmpSliderPercentage = 50
  self.state = 50
  self:register(updateSliderLevel)
end

function sliderButton:press(mapargs)
  self.pressed = true
  self:dragScrollbar(mapargs)
end

--This moves the scrollbar when interacting with the scrollbar itself "Chassis_Stiffness_Front.Slider.height"
function sliderButton:dragScrollbar(mapargs)
  if (self.pressed == true) then
    local y = mapargs.context_event_data.y - gre.get_value(self.control .. "._Ellipse____Pixellaag.grd_y")
    if (y >= 0) then
      local maxY = gre.get_value(self.control .. "._Ellipse____Pixellaag.grd_height") - gre.get_value(self.control .. "._Ellipse____Pixellaag.height")
      if (y > maxY) then
        y = maxY
      end
      gre.set_value(self.control .. "._Ellipse____Pixellaag.y", y)
      self.tmpSliderPercentage = math.floor(y/maxY * 100)
    end
  end
end

function sliderButton:release(mapargs)
  self.pressed = false
  self.state = self.tmpSliderPercentage
  print(self.state)
end


return sliderButton