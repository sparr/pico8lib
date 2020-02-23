pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib class library
-- by sparr


------------------------------------------------------------------------
-- create a new class from a parent class, with optional prototype
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

-- -- usage example:
-- thingclass = class(nil, {x=0, y=0, __init = function(self, x, y) self.x=x self.y=y})
-- movablethingclass = class(thing, {move = function() x=x+1 y=y+1 end})
-- amt = movablethingclass(3,5)
-- -- this calls getmetatable(amt).__init(amt,3,5)
-- -- but getmetatable(amt) doesn't have __init, so getmetatable(getmetatable(amt)).__index.__init is called
-- -- this resolves to thingclass.__init which does exist
-- -- so in the end this does thingclass.__init(amt,3,5)
-- amt.move()
-- print(amt.x)
-- print(amt.y)
-- -- amt.x is now 4, amt.y is now 6