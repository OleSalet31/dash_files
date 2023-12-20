-- Importing Lua files 
-- Here we import other Lua files which control different buttons
local ToggleButton = require("components.ToggleButton")
local GroupedButton = require("components.GroupedButton")
local VolumeButton = require("components.VolumeButton")
local TextView = require("components.TextView")
local StateListener = require("components.StateListener")
local RotaryButton = require("components.RotaryButton")

-- Contains the state of all the Buttons and Views
local ev_state = {}

---
-- Function that is called when a button updates a state
-- The function gets a button id and the value of that button.
-- It updates the ev_state and then sends the ev_state to the backend (CAN bus).
-- 
local function update_ev_state(id, value)
  -- We update the ev_state with this new value
  ev_state[id] = value
  
  ---    
  -- This sends an outgoing event, which is picked up by the backend.
  -- The first argument is the Event Name,
  -- Then the second is the Event data tyoes (you can copy these from the events page)
  -- The third argument is the ev_state table, containing all the button ID's with their corresponding value.
  -- Lastly we add the event channel. 
  -- This channel needs to be the same here and in the backend so they can communicate over the same channel.
  gre.send_event_data(
    "update_outgoing", 
    "2u1 t_battery 2u1 voltage 2u1 t_motor_lf 2u1 t_motor_rf 2u1 t_motor_lr 2u1 t_motor_rr 2u1 range 2u1 usage 2u1 usage_km 4u1 distance_travelled 2u1 trip 1u1 rear_windshield_heater 1u1 front_windshield_heater 1u1 windshield_washer 1u1 windshield_wiper 1u1 fog_light 1u1 spotlight 1u1 chargeport 1u1 central_lock 1u1 service 1u1 ac_inverter 1u1 cluster_menu 1u1 air_flow 1u1 blower_speed 1u1 ac_mode 1u1 ac_state 1u1 temp 1u1 seat_heating_left 1u1 seat_heating_right 1u1 battery_soc 1u1 regen_braking 1u1 creep_mode 1u1 reset_trip lul chassis_height 1u1 low_beam",    
    ev_state, 
    "update_outgoing"
  )
end

---
-- This table contains all the different page tables we are creating under here.
-- Whenever you create a new page and you add buttons or views to that page, you will need to add that page to this table.
-- This way, when new data is received from the backend the buttons and views can be updated.
-- If you do not add a page to the pages table it will not be updated from the backend!
local pages = {}

---
-- Here we start defining the buttons and views we have in our GUI.
-- The buttons are divided into different tables for every page.
-- This is not strictly necessary, but it makes it more organized.
-- 
-- So every page has a table. 
-- For example the access page has the 'accessPage' table.
-- Then we can add buttons and views to this table.
-- There are differnt buttons and views which need to be initialized differently,
-- but they all need to be added to the table.
-- 
-- The buttons also need to defined in the comment above the table initialization.
-- So above 'accessPage = {}' we first add '@type accessPage' 
-- and then for every button we do "@field <ButtonClass>#<buttonClass> <buttonName>".
-- Where buttonName needs to be the same the variable name and the control name.
-- So for example the central_lock button is of the class ToggleButton and the control is named central_lock.
-- So we add "@field components.ToggleButton#toggleButton central_lock"
-- 
-- Lastly we add the accessPage to the pages table.
-- "table.insert(pages, accessPage)"
--

-------------------------------------------------------------------------------------------------
-------------------------------------- ACCESS PAGE BUTTONS --------------------------------------
-------------------------------------------------------------------------------------------------

---
--@type accessPage
--@field components.ToggleButton#toggleButton front_windshield_heater
--@field components.ToggleButton#toggleButton rear_windshield_heater
--@field components.ToggleButton#toggleButton windshield_washer
--@field components.ToggleButton#toggleButton windshield_wiper
--@field components.ToggleButton#toggleButton fog_light
--@field components.ToggleButton#toggleButton spotlight
--@field components.ToggleButton#toggleButton chargeport
--@field components.ToggleButton#toggleButton central_lock
--@field components.ToggleButton#toggleButton ac_inverter
--@field components.VolumeButton#volumeButton cluster_menu
accessPage = {}

-- Left Menu
accessPage.front_windshield_heater = ToggleButton:new("Access.left_buttons.front_windshield_heater", update_ev_state)
accessPage.rear_windshield_heater = ToggleButton:new("Access.left_buttons.rear_windshield_heater", update_ev_state)
accessPage.windshield_washer = ToggleButton:new("Access.left_buttons.windshield_washer", update_ev_state)
accessPage.windshield_wiper = ToggleButton:new("Access.left_buttons.windshield_wiper", update_ev_state)

-- Right Menu
accessPage.fog_light = ToggleButton:new("Access.right_buttons.fog_light", update_ev_state)
accessPage.spotlight = ToggleButton:new("Access.right_buttons.spotlight", update_ev_state)
accessPage.chargeport = ToggleButton:new("Access.right_buttons.chargeport", update_ev_state)
accessPage.central_lock = ToggleButton:new("Access.right_buttons.central_lock", update_ev_state)

accessPage.ac_inverter = ToggleButton:new("Access.right_buttons.ac_inverter", update_ev_state)


--- Cluster Menu
-- The 3 number arguments are (in order) for initial state, min state and max state.
-- The boolean says that when a min or max limit is reached, the value 'loops around'.
-- So if the value goes past the max value it will become the min value and vice versa.
accessPage.cluster_menu = VolumeButton:new("cluster_menu", 
                                    "Access.cluster_menu.left_button", 
                                    "Access.cluster_menu.right_button", 
                                    update_ev_state, 0, 0, 3, true)
                                    
                        


---------------------------------------- CUSTOM FUNCTIONS ---------------------------------------

---
-- The custom functions 'listen' to updates of a state that they listen to.
-- The it uses the Crank function to update a Crank variable, which is bound to a render extension of a control.
-- So it is for example bound to an alpha variable (controling opacity) of a render extension.
-- The function has a 'self'-argument. You can access all variables of the 'StateListener' through this argument.
-- Through this we can access the state, however you could (if you want) also change the state from here. 

---
-- The spotlight_listener listens to any update of the spotlight state.
-- Then it turns the lights on or off in the center image.  
local function update_spotlights(self)
  if 1 == self.state then
    gre.set_value("Access.lights.spots_on_control.alpha", 255)
  else
    gre.set_value("Access.lights.spots_on_control.alpha", 0)
  end
end
accessPage.spotlight_listener = StateListener:new("spotlight", update_spotlights)

---
-- The spotlight_listener listens to any update of the spotlight state.
-- Then it turns the lights on or off in the center image.  
local function update_main_lights(self)
  if 1 == self.state then
    gre.set_value("Access.lights.main_lights_on_control.alpha", 255)
  else
    gre.set_value("Access.lights.main_lights_on_control.alpha", 0)
  end
end
accessPage.low_beam_listener = StateListener:new("low_beam", update_main_lights)

table.insert(pages, accessPage)

-------------------------------------------------------------------------------------------------
-------------------------------------- CLIMATE PAGE BUTTONS -------------------------------------
-------------------------------------------------------------------------------------------------

---
--@type climatePage
--@field components.GroupedButton#groupedButton air_flow
--@field components.GroupedButton#groupedButton blower_speed
--@field components.GroupedButton#groupedButton ac_mode
--@field components.ToggleButton#toggleButton ac_state
--@field components.VolumeButton#volumeButton temp
--@field components.ToggleButton#toggleButton seat_heating_left
--@field components.ToggleButton#toggleButton seat_heating_right
climatePage = {}

climatePage.air_flow = GroupedButton:new("air_flow", 
                                          "Climate.air_flow.air_flow_1", 
                                          "Climate.air_flow.air_flow_1_2", 
                                          "Climate.air_flow.air_flow_2_3", 
                                          "Climate.air_flow.air_flow_3", 
                                          update_ev_state)
climatePage.blower_speed = GroupedButton:new("blower_speed", 
                                              "Climate.blower_speed.state_0", 
                                              "Climate.blower_speed.state_1", 
                                              "Climate.blower_speed.state_2", 
                                              "Climate.blower_speed.state_3", 
                                              update_ev_state)
climatePage.ac_mode = GroupedButton:new("ac_mode", "Climate.lower_buttons.fresh_air", "Climate.lower_buttons.lucht_recirculatie", update_ev_state)
climatePage.ac_state = ToggleButton:new("Climate.lower_buttons.ac_state", update_ev_state)

--- Temp buttons
-- The 3 numerical arguments are (in order) for initial state, min state and max state.
-- The boolean says that when the button reaches it's max it will not 'loop around' back to the min value, or vice versa.
climatePage.temp = VolumeButton:new("temp", 
                                    "Climate.temp_selector.cold_button", 
                                    "Climate.temp_selector.hot_button", 
                                    update_ev_state, 
                                    14, 0, 28,
                                    false)
                                                                        
climatePage.seat_heating_left = ToggleButton:new("Climate.seat_heating.seat_heating_left", update_ev_state)
climatePage.seat_heating_right = ToggleButton:new("Climate.seat_heating.seat_heating_right", update_ev_state)

---------------------------------------- CUSTOM FUNCTIONS ---------------------------------------

--- Air Flow Listener
-- Listens to updates on the air_flow state, then updates the center air flow lines accordingly.
local function update_air_flow(self)
  if 0 == self.state then
    gre.set_value("Climate.air_flow.air_flow_1_view.alpha", 255)
    gre.set_value("Climate.air_flow.air_flow_2_view.alpha", 0)
    gre.set_value("Climate.air_flow.air_flow_3_view.alpha", 0)
  elseif 1 == self.state then
    gre.set_value("Climate.air_flow.air_flow_1_view.alpha", 255)
    gre.set_value("Climate.air_flow.air_flow_2_view.alpha", 255)
    gre.set_value("Climate.air_flow.air_flow_3_view.alpha", 0)
  elseif 2 == self.state then
    gre.set_value("Climate.air_flow.air_flow_1_view.alpha", 0)
    gre.set_value("Climate.air_flow.air_flow_2_view.alpha", 255)
    gre.set_value("Climate.air_flow.air_flow_3_view.alpha", 255)
  else
    gre.set_value("Climate.air_flow.air_flow_1_view.alpha", 0)
    gre.set_value("Climate.air_flow.air_flow_2_view.alpha", 0)
    gre.set_value("Climate.air_flow.air_flow_3_view.alpha", 255)
  end
end
climatePage.air_flow_listener = StateListener:new("air_flow", update_air_flow)

--- Temperature Listener
-- Listens to the temp state, then updates the temp_bar accordingly.
local update_temp = function(self)
  -- Control of the temperature bar image
  local temp_slider_control = "Climate.temp_selector.temp_selector"
  
  --- 
  -- This function controls the temperature bar, between the hot and cold buttons.
  -- The bar consist of 29 individual bars, each bar is around 14 pixels high.
  -- If the temperature is neutral the height of the mask is 14 pixels, and the y position of the mask is 0 pixels.
  -- Important here is that in Crank the alignment of the temp_bar image is centered. You can set this in the properties tab.
  -- The calculation under here are made to show the correct amount of pixels for the current state.
  
  -- The state in the backend however goes from 0 to 28. So we need to subtract 14 to be able to do our calculations correctly.
  
  
  local state = self.state - 14

  local height = 14 * -state
  local y = height / 2
  
  gre.set_value(temp_slider_control .. ".mask_y", y)
  gre.set_value(temp_slider_control .. ".mask_height",  14 + math.abs(height))
  
  if self.state > 14 then
  gre.set_value("Climate.temp_selector.temp_selector.angle", 360)
  end
  if self.state  < 14 then
  gre.set_value("Climate.temp_selector.temp_selector.angle", 180)
end
end

climatePage.temp_listener = StateListener:new("temp", update_temp)


table.insert(pages, climatePage)



-------------------------------------------------------------------------------------------------
--------------------------------------- DATA PAGE BUTTONS --------------------------------------
-------------------------------------------------------------------------------------------------

---
--@type dataPage
--@field components.TextView#textView t_battery
--@field components.TextView#textView voltage
--@field components.TextView#textView t_motor_lf
--@field components.TextView#textView t_motor_rf
--@field components.TextView#textView t_motor_lr
--@field components.TextView#textView t_motor_rr
--
--@field components.ToggleButton#toggleButton service
--
dataPage = {}

dataPage.battery_temp = TextView:new("Battery_Data.right_stats.t_battery")
dataPage.voltage = TextView:new("Battery_Data.right_stats.voltage")

dataPage.t_motor_lf = TextView:new("Battery_Data.motor_info.t_motor_lf")
dataPage.t_motor_rf = TextView:new("Battery_Data.motor_info.t_motor_rf")
dataPage.t_motor_lr = TextView:new("Battery_Data.motor_info.t_motor_lr")
dataPage.t_motor_rr = TextView:new("Battery_Data.motor_info.t_motor_rr")

dataPage.service = ToggleButton:new("Battery_Data.service.service", update_ev_state)

table.insert(pages, dataPage)

-------------------------------------------------------------------------------------------------
--------------------------------------- DATA PAGE BUTTONS --------------------------------------
-------------------------------------------------------------------------------------------------

---
--@type rangePage
--@field components.TextView#textView battery_soc
--@field components.TextView#textView range
--@field components.TextView#textView usage
--@field components.TextView#textView usage_km
--@field components.TextView#textView trip
--@field components.TextView#textView distance_travelled
--@field components.ToggleButton#toggleButton creep_mode
--@field components.ToggleButton#toggleButton reset_trip
--@field components.ToggleButton#toggleButton ride_height
--@field components.GroupedButton#groupedButton regen_braking
--@field components.GroupedButton#groupedButton chassis_height
rangePage = {}

rangePage.battery_soc = TextView:new("Battery_Range.battery.battery_soc")

rangePage.range = TextView:new("Battery_Range.range_info.range")
rangePage.usage = TextView:new("Battery_Range.range_info.usage")
rangePage.usage_km = TextView:new("Battery_Range.range_info.usage_km")
rangePage.distance_travelled = TextView:new("Battery_Range.range_info.distance_travelled")
rangePage.trip = TextView:new("Battery_Range.range_info.trip")

rangePage.creep_mode = ToggleButton:new("Battery_Range.creep_mode.creep_mode", update_ev_state)

rangePage.reset_trip = ToggleButton:new("Battery_Range.reset_trip.reset_trip", update_ev_state)

rangePage.chassis_height = GroupedButton:new("chassis_height",
                                              "Battery_Range.chassis_height.low_on",
                                              "Battery_Range.chassis_height.normal_on",
                                              "Battery_Range.chassis_height.high_on",
                                              update_ev_state)
rangePage.regen_braking = GroupedButton:new("regen_braking", 
                                            "Battery_Range.brake_recuperation.off_on", 
                                            "Battery_Range.brake_recuperation.low_on", 
                                            "Battery_Range.brake_recuperation.standard_on", 
                                            "Battery_Range.brake_recuperation.high_on", 
                                            update_ev_state)
                                            

---------------------------------------- CUSTOM FUNCTIONS ---------------------------------------

--- Open Ride Height
-- The open ride height button is not a normal toggle button.
-- As it does not control a state on the CAN-bus, but it controls the `hide` property of the chassis_height group.
local function open_ride_height(id, state)
  -- We have 2 tables one which says hidden is true(1) 
  -- and one which says hidden is false(0). 
  -- This way we can use these tables to set a group to hidden or shown.
  local hide = {}
  local show = {}
  hide['hidden'] = 1
  show['hidden'] = 0
  
  -- We check te state of the button, if it is on we want to show the chassis_height and vice versa.
  if state == 1 then
    gre.set_group_attrs("Battery_Range.afbeelingen_auto",hide)
    gre.set_group_attrs("Battery_Range.battery",hide)
    gre.set_group_attrs("Battery_Range.chassis_height",show)
  else 
    gre.set_group_attrs("Battery_Range.afbeelingen_auto",show)
    gre.set_group_attrs("Battery_Range.battery",show)
    gre.set_group_attrs("Battery_Range.chassis_height",hide)
  end
end                                            
rangePage.ride_height = ToggleButton:new("Battery_Range.ride_height.ride_height", open_ride_height)

--- Chassis Height Listener
-- This function listens to updates of the chassis height. Then updates the chassis height car image accordingly.
local function chassis_height_update(self)
  if self.state == 0 then
    gre.set_value("Battery_Range.chassis_height.low_control.alpha", 255)
    gre.set_value("Battery_Range.chassis_height.mid_control.alpha", 0)
    gre.set_value("Battery_Range.chassis_height.high_control.alpha", 0)
  elseif self.state == 1 then
    gre.set_value("Battery_Range.chassis_height.low_control.alpha", 0)
    gre.set_value("Battery_Range.chassis_height.mid_control.alpha", 255)
    gre.set_value("Battery_Range.chassis_height.high_control.alpha", 0)
  else
    gre.set_value("Battery_Range.chassis_height.low_control.alpha", 0)
    gre.set_value("Battery_Range.chassis_height.mid_control.alpha", 0)
    gre.set_value("Battery_Range.chassis_height.high_control.alpha", 255)
  end
end
rangePage.chassis_height_listener = StateListener:new("chassis_height", chassis_height_update)

local interval = {}
local is_starting = true

--- Battery State of Charge Listener
-- This function listens to the battery_soc state and updates the width of the battery image. 
-- To show how full the battery is according to the state of charge.
local function battery_soc_update(self)
  -- First we check if 'is_starting' is true, because when it is true it means that the startup animation is in progress 
  -- and we do not want to update the width then.
  -- Once it's false, we clear the interval of the startup animation. Otherwise the interval will keep running.
  if is_starting then return else gre.timer_clear_interval(interval) end
  
  local width = 195 + (self.state * 3.4)
  
  gre.set_value("Battery_Range.afbeelingen_auto.full_battery_control.width", width)
end
rangePage.battery_soc_listener = StateListener:new("battery_soc", battery_soc_update)
                                       
---
-- This function is called when the battery_range page is opened. 
-- This will 'fill up' the battery from 0 to the current state of the battery.
-- Once the battery is 'filled up' we set 'is_starting' to false, so the 'battery_soc_update' function removes the interval, 
-- and can start updating the soc.           
function battery_soc_startup()
  is_starting = true
  local state = 0
  
  gre.set_value("Battery_Range.afbeelingen_auto.full_battery_control.width", 0)
  interval = gre.timer_set_interval(20,
                          function()
                            if state >= rangePage.battery_soc.state then
                              is_starting = false
                              return
                            else 
                              gre.set_value("Battery_Range.afbeelingen_auto.full_battery_control.width", 195 + (state * 3.4))
                              state = state + 1
                            end
                          end
                         )
end

table.insert(pages, rangePage)
-------------------------------------------------------------------------------------------------
---------------------------------------- END PAGE BUTTONS ---------------------------------------
-------------------------------------------------------------------------------------------------


--- 
-- 
-- This function is called whenever an update event comes from the backend.
-- It loops through the pages table.
-- The per page it loops through all the buttons and views of that page and updates the state.
-- Then lastly it updates the ev_state table with the new state.
-- 
-- @param gre#context mapargs
local function onIncomingUpdateEvent(mapargs)
  local ev = mapargs.context_event_data
  ev_state = ev
  
  for _, viewGroup in ipairs(pages) do
    for id, button in pairs(viewGroup) do
      if ev[button.buttonID] ~= nil and button.state ~= ev[button.buttonID] then
        button:set_state(ev[button.buttonID])
      end
    end
  end
end

---
-- This 'binds' the onIncomingUpdateEvent function to the "update" event.
-- So anytime "update" is received, onIncomingUpdateEvent is called.
-- 
gre.add_event_listener("update", onIncomingUpdateEvent)

