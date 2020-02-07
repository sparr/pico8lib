pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib number library
-- by sparr

------------------------------------------------------------------------
-- random range functions
-- originally inspired by https://www.lexaloffle.com/bbs/?pid=72829
-- todo tests
local function rand(x) -- (0 ... x-1), such as for pixel or grid offsets
 return flr(rnd(x))
end
local function randi(x) -- (0 ... x), such as for pixels in/on a rect
 return flr(rnd(x + 1))
end
local function randp(x) -- (1 ... x-1), such as for pixels in a rect
 return 1 + flr(rnd(x - 1))
end
local function randpi(x) -- (1 ... x), such as for lua list indices
 return 1 + flr(rnd(x))
end
local function randb(n, x) -- (n ... x-1)
 return flr(rnd(x - n)) + n
end
local function randbi(n, x) -- (n ... x)
 return flr(rnd(x + 1 - n)) + n
end
local function randfrac(n, x) -- (n ... x) for non-integer n and x
 return rnd(x - n + 0x.0001) + n

------------------------------------------------------------------------
-- count the 1 bits in a number
-- this version runs one loop per set bit, 26 tokens
local function popcount(n)
 local c = 0
 while n ~= 0 do
  c, n = c + 1, band(n, n - 0x.0001)
 end
 return c
end
-- this version runs in constant time, 42 tokens
-- constant time is 111% the one-set-bit time of the shorter loop function
local function popcount(v)
  v -= band(v * .5, 0x5555.5555)
  v = band(v, 0x3333.3333) + band(v *.25, 0x3333.3333)
  return band((band(v + v * .0625, 0x0f0f.0f0f) * 0x0101.0101) * 256, 63)
end
