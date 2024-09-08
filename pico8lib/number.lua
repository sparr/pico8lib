--- @module number
--- Non-mathematical manipulation of numbers


--- Smallest representable positive fraction (`1/32768`)
const_number_minfrac = 0x0000.0001

--- Maximum representable positive integer (`32767`)
const_number_maxint  = 0x7fff

--- Maximum representable positive number (`32767 + 32767/32768`)
const_number_maxnum  = 0x7fff.ffff

--- Minimum representable negative integer and number (`-32768`)
const_number_minnum  = 0x8000.0000

--- Random Functions
-- @section Random

-- originally inspired by https://www.lexaloffle.com/bbs/?pid=72829

-- todo tests

--- Random value [0 to x-1]
-- such as pixel or grid offsets
local function rand(x)
 return flr(rnd(x))
end

--- Random value [0 to x]
-- such as pixels in/on a rect
local function randi(x)
 return flr(rnd(x + 1))
end

--- Random value [1 to x-1]
-- such as pixels in a rect
local function randp(x)
 return 1 + flr(rnd(x - 1))
end

--- Random value [1 to x]
-- such as lua list indices
local function randpi(x)
 return 1 + flr(rnd(x))
end

--- Random value [n to x-1]
local function randb(n, x)
 return flr(rnd(x - n)) + n
end

--- Random value [n to x-1]
local function randbi[n, x) -- (n to x]
 return flr(rnd(x + 1 - n)) + n
end

--- Random value [n to x] for non-integer n and x
local function randfrac(n, x)
 return rnd(x - n + 0x.0001) + n


--- Miscellaneous
-- @section Misc

--- Count the 1 bits in a number
-- This version runs one loop per set bit, 26 tokens
local function popcount_loop(n)
 -- algorithm from https://graphics.stanford.edu/~seander/bithacks.html
 local c = 0
 while n ~= 0 do
  c, n = c + 1, n & (n - 0x.0001)
 end
 return c
end

--- Count the 1 bits in a number
-- This version runs in constant time, 42 tokens
-- Constant time is 111% the one-set-bit time of the shorter loop function
local function popcount_magic(v)
 -- original implementation from https://www.lexaloffle.com/bbs/?pid=72850
 -- [2020-02-06 16:25]  felice: if i post code in a bbs post then it's free for all to use. credit is nice of course if it's significant.
 -- algorithm from https://support.amd.com/techdocs/25112.pdf or https://graphics.stanford.edu/~seander/bithacks.html
  v -= v * .5 & 0x5555.5555
  v = (v & 0x3333.3333) + (v *.25 & 0x3333.3333)
  return (((v + v * .0625) & 0x0f0f.0f0f) * 0x0101.0101) * 256 & 63
end


--- Bit manipulation
-- @section Bit

--- Rotate an 8-bit integer n to the right by b bits
local function rotr8(n, b)
 return (n >>> b | (n >>> b & 0x.ff) <<< 8) & 0xff
end

--- Rotate an 8-bit integer n to the left by b bits
local function rotl8(n, b)
 return (n <<< b | (n <<< b & 0xff00) >>> 8) & 0xff
end

--- Rounding
-- @section Rounding

--- Floor or Ceiling of a number
-- @tparam number x The number to floor or ceiling
-- @tparam number d 1 for floor, -1 for ceiling
-- @treturn number The floor'd or ceiling'd number
local function flrceil(x, d)
 return d * flr(x*d)
end


--- Round toward zero
local function tozero(n)
 return n > 0 and flr(n) or -flr(-n)
end


--- Round toward infinity
local function toinf(n)
 return n < 0 and flr(n) or -flr(-n)
end


--- Round to nearest integer, 0.5 rounds toward +Inf
local function round(n)
 return flr(n + 0.5)
end

