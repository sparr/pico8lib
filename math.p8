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
-- greatest common divisor of two numbers, recursive
local function gcd_recursive(a, b)
 return a==0 and b or gcd_recursive(b%a, a)
end
-- greatest common divisor of two numbers, iterative
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
-- distance functions partially thanks to https://www.lexaloffle.com/bbs/?pid=119363

-- distance calculation
-- uses dist_naive for small values, dist_trig for large
-- tokens: 46
function dist(x,y)
 if (abs(x) < 128 and abs(y) < 128) return dist_naive(x,y)
 return dist_trig(x,y)
end

-- naive distance calculation
-- tokens: 15
-- cycles: 9 + 28 = 37 (lua+sys)
-- numerical issues: breaks down for dist*dist>=32768, can cause big problems
function dist_naive(x,y)
 return sqrt(x*x+y*y)
end

-- distance calculation using trig
-- tokens: 23
-- cycles: 21 + 0 = 21 (lua+sys)
-- error in range (0,0)-(127,127): max 0.0017, avg 0.0004
function dist_trig(x,y)
 local a=atan2(x,y)
 return x*cos(a)+y*sin(a)
end

-- distance squared
local function dist_squared(x, y)
 return x * x + y * y
end

-- more complex distance and collision/overlap functions can be found in physics.p8


------------------------------------------------------------------------
-- approximation of asin(d) for 0<=d<=.7071
-- exact at d==0, d==sin(1/16), d==sin(1/8)
-- max error .0021 at d==sin(3/32) in given range
-- error within that max beyond bounds up to d==sin(.137)
-- asin() is the inverse of sin(); a=asin(d) when d=sin(a)
local function asin_octant(d)
 return d * 0x.29cf + (d > 0x.61f8 and (d - 0x.61f8) * 0x.0785 or 0)
end


------------------------------------------------------------------------
-- linear interpolation between a and b
-- (a,b,0) == a
-- (a,b,1) == b
-- (a,b,0.25) is 1/4 of the way from a to b
local function interp_linear(a, b, f) -- "lerp"
 return a + (b - a) * f
end


------------------------------------------------------------------------
-- inverse of linear interpolation between a and b
-- "how far along the way from a to b is v?"
-- (a,b,a) == 0
-- (a,b,b) == 1
-- (a,b,(a+b)/2) == 0.5
local function interp_linear_inverse(a, b, v)
 return (mid(a,v,b) - a) / (b - a)
end


------------------------------------------------------------------------
-- sine interpolation between a and b
-- (a,b,0) == a
-- (a,b,1) == b
-- (a,b,0.5) == 70.71% of the way from a to b
local function interp_sine(a, b, f)
 return a + (b - a) * -(sin(f/4))
end


------------------------------------------------------------------------
-- smoothstep interpolation between a and b
-- https://en.wikipedia.org/wiki/smoothstep
local function interp_smoothstep(a, b, x)
 x = mid(0, x, 1)
 return x * x * (3 - 2 * x) * (b - a) + a
end
local function interp_smootherstep(a, b, x)
 x = mid(0, x, 1)
 return x * x * x * (x * (x * 6 - 15) + 10) * (b - a) + a
end
local function interp_smootheststep(a, b, x)
 x = mid(0, x, 1)
 return x * x * x * x * (x * (x * (70 - 20 * x) - 84) + 35)
end
