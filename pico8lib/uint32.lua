--- @module uint32
--- Unsigned 32-bit Integers

-- one uint32 is stored as a single pico8 16.16bit fixed point number
-- based on https://github.com/jaredkrinke/pico-8-fbg/blob/master/fbg.p8
-- "sure, you have my permission to use the code from those two repositories (i'm the sole author) under the unlicense license (instead of mit) if you prefer." - jaredkrinke


--- @type uint32
local uint32
uint32 = setmetatable({

 --- Internal raw represenation of the uint32 value as a 16.16 fixed point number
 raw = 0,

 --- Overflow flag
 overflow = false,

 --- Cached decimal formatted representation
 repr = "0",

 --- Last raw value to be converted to decimal
 repr_raw = 0,

 --- Equality Operation
 -- Only called for uint32==uint32
 -- @tparam uint32 a
 -- @tparam uint32|number b
 -- @treturn Boolean `a==b`
 __eq = function (a, b)
  return a.raw == b.raw
 end,

 --- Less Than Operation
 -- @tparam uint32 a
 -- @tparam uint32 b
 -- @treturn Boolean `a<b`
 __lt = function (a, b)
  if (type(a) == "number") a,b=b,a
  if (type(a) == "number") a=uint32(a)
  -- negative raw values represent unsigned values greater than any positive raw value
  if a.raw < 0 then
   if b.raw >= 0 then
    return false
   else
    return a.raw < b.raw
   end
  end
  if b.raw < 0 then
   if a.raw >= 0 then
    return true
   else
    return b.raw <= a.raw
   end
  end
  return a.raw < b.raw
 end,

 --- Unary Minus Operation
 -- Always underflows for unsigned type
 -- @tparam uint32 u
 -- @treturn uint32 `-u`
 __unm = function (u)
  return 0 - u
 end,

 --- Addition Operation
 -- @tparam uint32 a
 -- @tparam uint32 b
 -- @treturn uint32 `a+b`
 __add = function (a, b)
  if (type(a) == "number") a=uint32(a)
  if (type(b) == "number") b=uint32(b)
  -- -- sum without overflow flag
  -- return uint32.from_raw(a.raw + b.raw)
  -- sum with overflow flag
  local sum = uint32.from_raw(a.raw + b.raw)
  sum.overflow = sum < a or sum < b
  return sum
 end,

 --- Subtraction Operation
 -- @tparam uint32 a
 -- @tparam uint32 b
 -- @treturn uint32 `a-b`
 __sub = function (a, b)
  if (type(a) == "number") a,b=b,a
  if (type(a) == "number") a=uint32(a)
  -- -- difference without overflow flag
  -- return uint32.from_raw(a.raw - b.raw)
  -- difference with overflow flag
  local diff = a.raw - b.raw
  return uint32.from_raw(diff, a.raw >= 0 and b.raw < 0 or sgn(a.raw) == sgn(b.raw) and a.raw < b.raw) -- todo test thoroughly
 end,

 --- Multiplication Operation
 -- @tparam uint32 a
 -- @tparam uint32|number b
 -- @treturn uint32 `a*b`
 __mul = function (a, b)
  -- TODO test!
  if (type(a) == "number") a,b=b,a
  if type(a) == "number" then
   -- TODO detect overflow
   return uint32.from_raw(a * b.raw)
  end
  if a.raw<1 and a.raw>-1 and b.raw<1 and b.raw>-1 then
   -- values betwen -32768 and 32767 can be multiplied losslessly with shifting
   return uint32.from_raw(((a.raw << 16) * b.raw))
  end
  local acc = 0
  for bit = 0, 31 do
   if a.raw>>bit & 0x0000.0001 > 0 then
    acc += b.raw << bit
   end
  end
  return uint32.from_raw(acc)
 end,

 --- String Concatenation Operation
 -- @tparam uint32 a
 -- @tparam uint32 b
 -- @treturn string `tostr(a) .. tostr(b)`
 __concat = function (a, b)
  if (getmetatable(a) == uint32) a = a:__tostring()
  if (getmetatable(b) == uint32) b = b:__tostring()
  return a .. b
 end,

 --- Create a new uint32 from a raw value and overflow
 -- @tparam number raw
 -- @tparam[opt] Boolean overflow
 -- @treturn uint32
 from_raw = function(raw, overflow)
  u = uint32(0, overflow)
  u.raw = raw
  return u
 end,

 --- Create a new uint32 from a raw value and overflow
 -- @tparam int a LSB
 -- @tparam int b
 -- @tparam int c
 -- @tparam int d MSB
 -- @tparam[opt] Boolean overflow
 -- @treturn uint32
 create_from_bytes = function(a, b, c, d, overflow)
  return from_raw(a >>> 16 | b >>> 8 | c | d << 8, overflow)
 end,

},{

 --- Constructor
 -- @tparam class t uint32 class
 -- @tparam number|uint32 val
 -- @tparam[opt] Boolean overflow
 -- @treturn uint32
 __call=function(t, val, overflow)
  if getmetatable(val) == uint32 then
   raw = val.raw
  else
   raw = lshr(val, 16)
  end
  return setmetatable({ raw = raw, overflow = overflow }, t)
 end

})
uint32.__index = uint32

local function decimal_digits_add_in_place(a, b)
 local carry = 0
 local i = 1
 local digits = max(#a, #b)
 while i <= digits or carry > 0 do
  local left = a[i] or 0
  local right = b[i] or 0
  local sum = left + right + carry
  a[i] = sum % 10
  carry = flr(sum / 10)
  i = i + 1
 end
end

local function decimal_digits_double(a)
 local result = {}
 for i = 1, #a, 1 do result[i] = a[i] end
 decimal_digits_add_in_place(result, a)
 return result
end

local uint32_binary_digits = { { 1 } }
function uint32:format_decimal()
 local result_digits = { 0 }
 local raw = self.raw

 -- find highest bit
 local max_index = 0
 local v = raw
 while v ~= 0 do
  v = lshr(v, 1)
  max_index = max_index + 1
 end

 -- compute the value
 for i = 1, max_index, 1 do
  -- make sure decimal representation of this binary bit is cached
  local binary_digits = uint32_binary_digits[i]
  if binary_digits == nil then
   binary_digits = decimal_digits_double(uint32_binary_digits[i - 1])
   uint32_binary_digits[i] = binary_digits
  end

  -- find the bit
  local mask = 1
  if i <= 16 then
   mask = lshr(mask, 16 - (i - 1))
  elseif i > 17 then
   mask = shl(mask, (i - 1) - 16)
  end

  local bit = false
  if mask & raw ~= 0 then bit = true end

  -- add, if necessary
  if bit then
   decimal_digits_add_in_place(result_digits, binary_digits)
  end
 end

 -- concatenate the digits
 local str = ""
 for i = #result_digits, 1, -1 do
  str = str .. result_digits[i]
 end
 return str
end

function uint32:__tostring(raw)
 if (raw) return tostr(self.raw, true)
 -- cache format_decimal result
 if self.repr_raw ~= self.raw then
  self.repr = self:format_decimal()
  self.repr_raw = self.raw
 end
 return self.repr
end

uint32.zero = uint32(0)
uint32.one = uint32(1)
uint32.maxint = uint32.from_raw(0xFFFF.FFFF)