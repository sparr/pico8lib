include ../pico8lib/class.lua

-- create a new class called thingclass
-- it has no parent class
-- its prototype has x and y fields, and a constructor to set them
thingclass = class(nil, {x=0, y=0, __init = function(self, x, y) self.x=x self.y=y})

-- create a new class called movablethingclass
-- it inherits from parent thingclass
-- it had a new function move() that modifies the x and y fields
movablethingclass = class(thingclass, {move = function() x=x+1 y=y+1 end})

amt = movablethingclass(3,5)
-- this calls getmetatable(amt).__init(amt,3,5)
-- but getmetatable(amt) doesn't have __init, so getmetatable(getmetatable(amt)).__index.__init is called
-- this resolves to thingclass.__init which does exist
-- so in the end this does thingclass.__init(amt,3,5)

amt.move()
print(amt.x)
print(amt.y)
-- amt.x is now 4, amt.y is now 6