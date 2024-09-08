--- @module vector
--- Vectors (points and directions)

-- A vector is a point or direction in 2d space
-- represented by an x and y coordinate
-- vector arithmetic represents operations on these points/directions

-- some code from https://github.com/codekitchen/pico-8-circuits
-- MIT license, details in LICENSE file

-- pico8 coordinate system
-- +x is east/right
-- -x is west/left
-- +y is south/down
-- -y is north/up
-- 0,0 is the top left corner of the screen

--- @type Vector
local vector
vector = setmetatable({

 --- X coordinate
 x = 0,

 --- Y coordinate
 y = 0,

 --- Equality operation
 -- @tparam Vector a
 -- @tparam Vector b
 -- @treturn Boolean
 __eq = function(a, b)
  return a.x == b.x and a.y == b.y
 end,

 --- Unary Minus operation
 -- @tparam Vector v
 -- @treturn Vector
 __unm = function(v)
  return vector{ -v.x, -v.y }
 end,

 --- Addition operation
 -- @tparam Vector a
 -- @tparam Vector b
 -- @treturn Vector
 __add = function(a, b)
  return vector{ a.x + b.x, a.y + b.y }
 end,

 --- Subtraction operation
 -- @tparam Vector a
 -- @tparam Vector b
 -- @treturn Vector
 __sub = function(a, b)
  return vector{ a.x - b.x, a.y - b.y }
 end,

 --- Mutliplication operation, Scalar Product (alias `scalarproduct`)
 -- @tparam Vector a
 -- @tparam Vector b
 -- @treturn number
 __mul = function(a, b)
  if (type(a) == "number") a,b = b,a
  if (type(b) == "number") return vector{ a.x * b, a.y * b }
  return a.x * b.x + a.y * b.y
 end,

 --- Cross Product
 -- @tparam Vector a
 -- @tparam Vector b
 -- @treturn number Magnitude of the cross product
 crossproduct = function(a, b)
  return a.x * b.y - a.y * b.x
 end,

 --- Division operation, Scalar Division
 -- @tparam Vector v
 -- @tparam number n
 -- @treturn Vector
 __div = function(v, n)
  return vector{ v.x / n, v.y / n }
 end,

 --- Magnitude (alias `mag`)
 -- @tparam Vector v
 -- @treturn number Magnitude of this Vector
 __len = function(v)
  -- based on math.p8 dist()
  local x, y = abs(v.x), abs(v.y)
  if (x < 128 and y < 128) return sqrt(x*x+y*y)
  local a=v:angle()
  return x*cos(a)+y*sin(a)
 end,

 --- String representation
 -- @tparam Vector v
 -- @treturn string [vector:0,0]
 __tostring = function(v)
  return "[vector:" .. tostr(v.x) .. "," .. tostr(v.y) .. "]"
 end,

 --- Magnitude squared
 -- @tparam Vector v
 -- @treturn number Magnitude of this Vector, squared
 magsqr = function(v)
  return v.x * v.x + v.y * v.y
 end,

 --- Angle of this vector
 -- @tparam Vector v
 -- @treturn number Angle [0-1) from the origin to this Vector
 angle = function(v)
  return atan2(v.x, -v.y)
 end,

 --- Normalized vector
 -- @tparam Vector v
 -- @treturn Vector A Vector with the same angle as this Vector and magnitude 1
 normalize = function(v)
  return v / #v
 end,

 --- Vector contained within rectangle
 -- @tparam Vector v
 -- @tparam Vector p1 Top left corner of rectangle
 -- @tparam Vector p2 Bottom right corner of rectangle
 -- @treturn boolean Is `a` within [p1,p2]?
 contained = function(v, p1, p2)
  return v.x >= p1.x and v.x <= p2.x and v.y >= p1.y and v.y <= p2.y
 end,

 --- Store in persistent cartridge storage
 -- @tparam Vector v
 -- @tparam int idx First storage index in [0,62], also uses `idx+1`
 dset = function(v, idx)
  dset(idx, v.x)
  dset(idx+1, v.y)
 end,

 -- TODO extract "static" methods and differentiate them in ldoc

 --- Retrieve from persistent cartridge storage
 -- @tparam int idx First storage index in [0,62], also reads `idx+1`
 -- @treturn Vector
 dget = function(idx)
  return vector{dget(idx), dget(idx + 1)}
 end,

 --- Return this vector rotated 90 degrees
 -- @tparam Vector v
 -- @treturn Vector A Vector with the same magnitude as this Vector and an angle rotated 90 degrees
 rotate_90 = function(v)
  return vector{-v.y, v.x}
 end,

 --- Return this vector rotated 180 degrees
 -- @tparam Vector v
 -- @treturn Vector A Vector with the same magnitude as this Vector and an angle rotated 180 degrees
 rotate_180 = function(v)
  return -v
 end,

 --- Return this vector rotated 270 degrees
 -- @tparam Vector v
 -- @treturn Vector A Vector with the same magnitude as this Vector and an angle rotated 270 degrees
 rotate_270 = function(v)
  return vector{v.y, -v.x}
 end,

 --- Return this vector rotated a certain number of degrees
 -- @tparam Vector v
 -- @tparam number angle Angle of rotation in degrees
 -- @treturn Vector A Vector with the same magnitude as this Vector and an angle rotated the given amount
 rotate_degrees = function(v, angle)
  return v:rotate(angle / 360)
 end,

 --- Return this vector rotated a certain angle
 -- @tparam Vector v
 -- @tparam number angle Angle of rotation [0,1)
 -- @treturn Vector A Vector with the same magnitude as this Vector and an angle rotated the given amount
 rotate = function(v, angle) -- todo test
  return vector{v.x * cos(angle) + v.y * sin(angle), v.y * cos(angle) + v.x * -sin(angle)}
 end,

 --- Construct a Euclidean vector from a polar vector
 -- @tparam Polar p {r:number,t:number}
 -- @treturn Vector
 from_polar = function(p)
  return vector{p.r * cos(p.t), -p.r * sin(p.t)}
 end,

 --- Return the polar version of this vector
 -- @tparam Vector v
 -- @treturn Polar
 to_polar = function(v)
  return {r = #v, t = v:angle()}
 end,

 --- Reflect Vector across Normal
 -- @tparam Vector v
 -- @tparam Vector n
 -- @treturn Vector `v` reflected across `n`, as if `n` was perpendicular to a mirror
 reflect = function(v, n)
  -- todo test
  -- note that v*n is a scalar dot product, then 2*that*n is a vector*scalar multiplication
  return v - 2 * (v * n) * n
 end
},{

 --- Constructor
 -- @tparam Vector v
 -- @tparam[opt] {number,number}|Vector t
 __call=function(v, t)
  t = t or {0,0}
  return setmetatable({ x = t[1] or t.x or 0, y = t[2] or t.y or 0}, v)
 end

})
vector.__index = vector
vector.mag = vector.__len
vector.scalarproduct = vector.__mul

--- Lookups
--- @section Lookups

--- Cardinal directions as vectors {E, S, W, N}
local vector_directions_4 = {}
vector_directions_4 = {vector{1, 0}, vector{0, 1}, vector{-1, 0}, vector{0, -1}}

--- Cardinal and diagonal directions as vectors {E, SE, S, SW, W, NW, N, NE}
local vector_directions_8 = {}
vector_directions_8 = {vector{1, 0}, vector{1, 1}, vector{0, 1}, vector{-1, 1}, vector{-1, 0}, vector{-1, -1}, vector{0, -1}, vector{1, -1}}

