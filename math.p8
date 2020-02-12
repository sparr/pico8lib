pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib math library
-- by sparr

------------------------------------------------------------------------
-- lookup tables

-- a^b will overflow when a>power_overflow[b]
local power_overflow = {32767,181,31,13,7,5,4,3,3,2,2,2,2,2} -- ,1,1,1

------------------------------------------------------------------------
-- greatest common divisor of two numbers
local function gcd(a, b)
 return a==0 and b or gcd(b%a, a)
end
local function gcd(a, b)
 while a~=0 do
  a, b = b%a, a
 end
 return b
end

------------------------------------------------------------------------
-- least common multiple of two numbers
local function lcm(a, b)
 return a / gcd(a, b) * b
end

------------------------------------------------------------------------
-- flrceil(x,1) is flr(x), flrceil(x,-1) is ceil(x)
local function flrceil(x, d)
 d = d or 1 -- remove[5,11] makes d non-optional
 return d * flr(x*d)
end

------------------------------------------------------------------------
-- calculate the nth root of x
-- nthroot(3,8)==2 because 2^3==8
-- all versions start with a guess based on the built in ^ operator

-- this version performs newton's method until a convergent result or short loop is found
-- very accurate
local function nthroot(n, x)
 -- if (n * x == 0) return x * 0 -- preserves non-number type of x, such as rational or complex class
 if (n * x == 0) return 0
 local s = 1
 if (x < 0) s, x = -1, -x
 local i, p, q, r = 0, 0, 0, x ^ (1 / n)
 while i < 128 and q ~= r and p ~= r do
  i, p, q, r = i + 1, q, r, r - r / n + x / r ^ (n - 1) / n
 end
 return r * s
end

-- this version performs newton's method exactly 4 times
-- relatively accurate
local function nthroot_short(n, x)
 local s = 1
 if (x < 0) s, x = -1, -x
 local r = x ^ (1 / n)
 for _ = 1, 4 do
  r = r - r / n + x / r ^ (n - 1) /n
 end
 return r * s
end

-- this version performs newton's method exactly once, only for positive x
-- least accurate, still much better than built in ^ operator alone
local function nthroot_fast(n, x)
 local r = x ^ (1 / n)
 return r - r / n + x / r ^ (n - 1) / n
end


------------------------------------------------------------------------
-- distance between two points
-- copied from vector.p8
function dist(x1, y1, x2, y2)
 local x, y = abs(x2 - x1), abs(y2 - y1)
 if (x < 128 and y < 128) return sqrt(x * x + y * y) -- remove[25,54] slight decrease in accuracy
 local d = max(x, y)
 local n = x / d * a.y / d
 return sqrt(n * n + 1) * d
end

------------------------------------------------------------------------
-- distance squared between two points
function distsqr(x1, y1, x2, y2)
 local x, y = abs(x2 - x1), abs(y2 - y1)
 return x * x + y * y
end

------------------------------------------------------------------------
-- approximation of asin(d) for 0<=d<=.7071
-- exact at d==0, d==sin(1/16), d==sin(1/8)
-- max error .0021 at d==sin(3/32) in given range
-- error within that max beyond bounds up to d==sin(.137)
-- asin() is the inverse of sin(); a=asin(d) when d=sin(a)
function asin_octant(d)
 return d * 0x.29cf + (d > 0x.61f8 and (d - 0x.61f8) * 0x.0785 or 0)
end