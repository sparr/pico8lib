pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib rational number library
-- by sparr

-- a rational number is a fraction, numerator/denominator
-- rational number arithmetic operates on the two parts of the fraction separately
-- rational numbers avoid floating point rounding errors in values like 1/3

local function nthroot(n,x) return x^(1/n) end -- much better alternatives in math.p8

local rational
rational = setmetatable({

 __len = function(a)
  return a.n / a.d -- single token conversion from rational to number
 end,

 __eq = function(a, b)
  return a.n == b.n and a.d == b.d
 end,

 __lt = function(a, b) 
  -- return #a<#b -- fast cheap imprecise
  if (type(a) == "number") return a < #b
  if (type(b) == "number") return #a < b
  lt = true
  n1, d1, n2, d2 = a.n, a.d, b.n, b.d
  while true do
   -- compare whole number part of fractions
   -- a+b/c<d+e/f is just a<d if a~=d
   q1, q2 = flr(n1 / d1), flr(n2 / d2)
   if (q1 < q2) return lt
   if (q2 > q1) return not lt
   -- subtract whole number parts
   -- a+b/c<d+e/f becomes b/c<e/f
   r1, r2 = n1 - q1 * d1, n2 - q2 * d2
   -- check if either side is now zero
   if (r1 == 0 and r2==0) return false
   if (r1 == 0) return lt
   if (r2 == 0) return not lt
   -- invert fractions and reverse comparison
   -- b/c<e/f becomes c/b>f/e
   n1, d1, n2, d2, lt = d1, r1, d2, r2, not lt
   -- repeat until one of the earlier checks resolves the comparison
  end
 end,

 __unm = function(a)
  return rational(-a.n, a.d)
 end,

 __add = function(a, b)
  if (type(a) == "number") return b + a
  if (type(b) == "number") return rational(a.n + b * a.d, a.d)
  local d = lcm(a.d, b.d)
  return rational(d / a.d * a.n + d / b.d * b.n, d)
 end,

 __sub = function(a, b)
  return a + -b
 end,

 __mul = function(a, b)
  if (type(a) == "number") return b * a
  if (type(b) == "number") b = rational(b, 1)
  return rational(a.n * b.n, a.d * b.d) -- todo avoid potentially unnecessary overflow after * before simplify()
 end,

 __div = function(a, b)
  if (a == 1 or rational.is(a) and #a == 1) return rational(b.d, b.n)
  local q
  if type(a) == "number" then q = rational(a * b.d, b.n)
  elseif type(b) == "number" then q = rational(a.n, a.d * b)
  else q = rational(a.n * b.d, a.d * b.n) end
  return q
 end,

 __mod = function(a, b)
  return a - b * flr(#(a / b))
 end,

 __pow = function(a, b)
  if (type(a) == "number") return nthroot(a, b.d) ^ b.n
  if type(b) == "number" then
   if b > 0 and b == flr(b) and (a.n > power_overflow[b] or a.d > power_overflow[b]) then
    return rational((#a) ^ b)
   end
   return rational(a.n ^ b, a.d ^ b)
  else
   return nthroot(b.d, rational(a.n ^ b.n, a.d ^ b.n))
  end
 end,

 __tostring = function(a, ...)
  return tostr(a.n, ...) .. "/" .. tostr(a.d, ...)
  -- longer version is useful if tostr() doesn't respect __tostring
  -- return type(a) == "number" and tostr(a, ...) or (tostr(a.n, ...) .. "/" .. tostr(a.d, ...))
 end,

 is = function(mt, a)
  return getmetatable(a) == mt
 end,

 simplify = function(a)
  if (a.d < 0) a.n, a.d = -a.n, -a.d -- overflow at d=-32768
  if (a.d == 1) return a
  local g = abs(gcd(a.n, a.d))
  if (g > 1) a.n /= g a.d /= g
  return a 
 end,

},{

 __call=function(t, n, d)
  local a, b
  if t:is(n) and t:is(d) then -- rational over rational
   a, b = n.n * d.d, n.d * d.n
  elseif t:is(n) then
   if flr(d) == (d or 0) then -- rational over integer/nil
    a, b = n.n, n.d * (d or 1)
   else -- rational over float
    return rational(n, rational(d))
   end
  elseif t:is(d) then -- nonrational over rational
   return 1 / t(d, n)
  elseif n == flr(n) and d == flr(d) then -- integer over integer
   a, b = n, d or 1
  elseif (not n or n == flr(n)) and not d then -- integer/nil over nil
   a, b = n or 0, 1
  elseif 1 / n == flr(1 / n) and not d then -- (1/x) over nil, mostly for rational(1/2^x)
   a, b = 1, 1 / n
  else -- noninteger over noninteger/nil
   -- try to find two ~8bit integers that divide to produce this float
   -- todo implement 2d binary search
   local q = n / (d or 1)
   local s = sgn(q)
   a, b, q = 0, 1, abs(q)
   while b <= 256 and a / b ~= q do
    if (a / b < q) a += 1
    if (a / b > q) b += 1
   end
   if a / b == q then -- found them
    a *= s
   else -- give up, accept a non-integer numerator as the last resort
    a, b = q*s, 1
   end
  end
  return setmetatable({n = a, d = b}, t):simplify()
 end

})
rational.__index=rational

-- useful constants
rational.zero=rational(0)
rational.one=rational(1)


------------------------------------------------------------------------
-- tests
-- todo