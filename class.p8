--- @module class
--- Easily create subclasses and object-oriented designs
-- @author sparr


--- create a new class
-- @tparam class parent the parent of this new class
-- @tparam[opt] table proto the prototype (default keys/values) for this new class 
-- @return class the new class
function class(parent, proto)
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
