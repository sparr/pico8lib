--- @module class
--- Easily create subclasses and object-oriented designs
-- @author sparr

--- Create a new class from a parent class, with optional prototype
-- @tparam class parent The parent of this new class
-- @tparam[opt] table proto A table definition of the child class (prototype/default keys/values)
-- @treturn class Constructor function for the newly defined class
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
