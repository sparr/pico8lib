pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib number library
-- by sparr

const_number_minfrac = 0x0000.0001 -- 1/32768
const_number_maxnum = 0x7fff.ffff -- 32677 + 32767/32768
const_number_minnum = 0x8000.0000 -- -32768


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
-- algorithm from https://graphics.stanford.edu/~seander/bithacks.html
local function popcount(n)
 local c = 0
 while n ~= 0 do
  c, n = c + 1, band(n, n - 0x.0001)
 end
 return c
end
-- this version runs in constant time, 42 tokens
-- constant time is 111% the one-set-bit time of the shorter loop function
-- original implementation from https://www.lexaloffle.com/bbs/?pid=72850
-- [2020-02-06 16:25]  felice: if i post code in a bbs post then it's free for all to use. credit is nice of course if it's significant.
-- algorithm from https://support.amd.com/techdocs/25112.pdf or https://graphics.stanford.edu/~seander/bithacks.html
local function popcount(v)
  v -= band(v * .5, 0x5555.5555)
  v = band(v, 0x3333.3333) + band(v *.25, 0x3333.3333)
  return band((band(v + v * .0625, 0x0f0f.0f0f) * 0x0101.0101) * 256, 63)
end


------------------------------------------------------------------------
-- rotate an 8-bit integer n to the right by b bits
local function rotr8(n, b)
 return band(bor(shr(n, b), shl(band(shr(n, b), 0x.ff), 8)),0xff)
end
-- rotate an 8-bit integer n to the left by b bits
local function rotl8(n, b)
 return band(bor(shl(n, b), shr(band(shl(n, b), 0xff00), 8)),0xff)
end


------------------------------------------------------------------------
-- flrceil(x,1) is flr(x), flrceil(x,-1) is ceil(x)
local function flrceil(x, d)
 d = d or 1 -- remove[5,11] makes d non-optional
 return d * flr(x*d)
end


------------------------------------------------------------------------
-- nearest integer toward zero
local function tozero(n)
 return n > 0 and flr(n) or -flr(-n)
end


------------------------------------------------------------------------
-- nearest integer toward +/- infinity
local function toinf(n)
 return n < 0 and flr(n) or -flr(-n)
end


------------------------------------------------------------------------
-- round a number to the nearest integer, 0.5 rounds up
local function round(n)
 return flr(n + 0.5)
end

