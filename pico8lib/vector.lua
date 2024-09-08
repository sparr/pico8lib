--- @module vector
--- pico8lib vector library
-- @author sparr
-- @author codekitchen

-- mit license, details in license file

-- a vector is a point or direction in 2d space
-- represented by an x and y coordinate
-- vectors arithmetic represents operations on these points/directions

-- pico8 coordinate system
-- +x is east/right
-- -x is west/left
-- +y is south/down
-- -y is north/up

-- some code from https://github.com/codekitchen/pico-8-circuits

local vector

vector = setmetatable({

 __eq = function(a, b)
  return a.x == b.x and a.y == b.y
 end,

 __unm = function(v)
  return vector{ -v.x, -v.y }
 end,

 __add = function(a, b)
  return vector{ a.x + b.x, a.y + b.y }
 end,

 __sub = function(a, b)
  return vector{ a.x - b.x, a.y - b.y }
 end,

 __mul = function(a, b)
  if (type(a) == "number") a,b = b,a
  if (type(b) == "number") return vector{ a.x * b, a.y * b }
  return a.x * b.x + a.y * b.y -- scalar product
 end,

 crossproduct = function(a, b)
  return a.x * b.y - a.y * b.x
 end,

 __div = function(a, b)
  return vector{ a.x / b, a.y / b }
 end,

-- based on math.p8 dist()
 __len = function(v)
  local x, y = abs(v.x), abs(v.y)
  if (x < 128 and y < 128) return sqrt(x*x+y*y)
  local a=v:angle()
  return x*cos(a)+y*sin(a)
 end,

 __tostring = function(v)
  return "[vector:" .. tostr(v.x) .. "," .. tostr(v.y) .. "]"
 end,

 -- magnitude squared
 magsqr = function(v)
  return v.x * v.x + v.y * v.y
 end,

 angle = function(v)
  return atan2(v.x, -v.y)
 end,

 normalize = function(a)
  return a / #a
 end,

 contained = function(a, p1, p2)
  return a.x >= p1.x and a.x <= p2.x and a.y >= p1.y and a.y <= p2.y
 end,

 dset = function(a, idx)
  dset(idx, a.x)
  dset(idx+1, a.y)
 end,

 dget = function(idx)
  return vector{dget(idx), dget(idx + 1)}
 end,

 rotate_90 = function(a)
  return vector{-a.y, a.x}
 end,

 rotate_180 = function(a)
  return -a
 end,

 rotate_270 = function(a)
  return vector{a.y, -a.x}
 end,

 --- Rotate a vector a certain number of degrees
 rotate_degrees = function(a, angle)
  return a:rotate(angle / 360)
 end,

 rotate = function(a, angle) -- todo test
  return vector{a.x * cos(angle) + a.y * sin(angle), a.y * cos(angle) + a.x * -sin(angle)}
 end,

 from_polar = function(p) -- todo test
  return vector{p.r * cos(p.t), -p.r * sin(p.t)}
 end,

 to_polar = function(a) -- todo test
  return {r = #a, t = a:angle()}
 end,

 -- reflection vector between vector a and normal n
 -- todo test
 reflect = function(a, n)
  return a - a * n * n * 2
 end
},{

 __call=function(t, o)
  o = o or {0,0}
  return setmetatable({ x = o[1] or o.x or 0, y = o[2] or o.y or 0}, t)
 end

})
vector.__index = vector
vector.mag = vector.__len

local vector_directions_4 = {vector{1, 0}, vector{0, 1}, vector{-1, 0}, vector{0, -1}}
local vector_directions_8 = {vector{1, 0}, vector{1, 1}, vector{0, 1}, vector{-1, 1}, vector{-1, 0}, vector{-1, -1}, vector{0, -1}, vector{1, -1}}

