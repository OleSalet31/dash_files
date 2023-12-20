---
-- @module class.lua
--
 
local class = {}
 
---
-- Creates a new object prototype by extending from the base object.
-- The new object prototype implements the new, init, class, super, and instanceOf functions
-- @param _ #table - Not used
-- @param base #table - The base object to extend for this new object prototype
-- @return #table the new object prototype
local function extend(_, base)
         local new_class = {}
         local class_mt = {__index = new_class}
 
         if base then
                     setmetatable(new_class, {__index=base})
         end
           
         ---
         -- Instantiates a new object
         -- @param ... - A list of arguments
         -- @return #table - The newly instantiated object
         function new_class:new(...)
         local inst = {}
         setmetatable(inst, class_mt)
         inst:init(...)
         return inst
         end
 
         ---
         -- Initializes the data for the new object. This function must be implemented by a subclass.
         -- @param ... - A list of arguments
         function new_class:init(...)
                     error("init must be implemented")
         end
 
         ---
         -- Get the current class prototype
         -- @return #table - Class prototype
         function new_class:class()
                     return new_class
         end
 
         ---
         -- Get the parent class prototype
         -- @return #table - Parent class prototype
         function new_class:super()
                     return base
         end
 
         ---
         -- Check if object is an instance of another class
         -- @param klass #table - A class to check against
         -- @return #boolean - True if object is an instance of klass
         function new_class:instanceOf(klass)
                     local is_a = false
                     local cur = new_class
                     while (cur and not is_a) do
                                 if (cur == klass) then
                                             is_a = true
                                 else
                                             cur = cur:super()
                                 end
                     end
 
                     return is_a
         end
 
         return new_class
end
 
-- allow the class object to be used as a function
setmetatable(class, {__call=extend})
 
return class