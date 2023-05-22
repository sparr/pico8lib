--- @module class
--- Easily create subclasses and object-oriented designs
-- @author sparr

--- Create a new class from a parent class, with optional prototype
-- @param parent The parent class to subclass, can be null
-- @param proto A table definition of the child class
-- @return a constructor function for the newly defined class
local function class(parent, proto)
 proto = setmetatable(proto or {}, {
  __index = parent,
  __call = function(self, ...)
   local instance = setmetatable({}, self)
   if self.__init then
    instance:__init(...)
   end
   return instance
  end
 })
 proto.__index = proto
 return proto
end
