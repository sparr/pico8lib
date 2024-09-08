pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib uint32 library
-- by sparr and jaredkrinke

-- this library implements unsigned 32-bit integers
-- one uint32 is stored as a single pico8 16.16bit fixed point number

-- based on https://github.com/jaredkrinke/pico-8-fbg/blob/master/fbg.p8
-- "sure, you have my permission to use the code from those two repositories (i'm the sole author) under the unlicense license (instead of mit) if you prefer."



local uint32
uint32 = setmetatable({

 __eq = function (a, b)
  return a.value == b.value
 end,

 __lt = function (a, b)
  return a.value < b.value
 end,

 __unm = function (a)
  return 0 - a
 end,

 __add = function (a, b)
  if type(a) == "number" then
   a = uint32(a)
  elseif type(b) == "number" then
   b = uint32(b)
  end
  -- -- sum without overflow flag
  -- return uint32.from_raw(a.value + b.value)
  -- sum with overflow flag
  local sum = a.value + b.value
  return uint32.from_raw(sum, (sgn(a.value) < 0 or sgn(b.value) < 0) and sgn(sum) == 1)
 end,

 __sub = function (a, b)
  if type(a) == "number" then
   a = uint32(a)
  elseif type(b) == "number" then
   b = uint32(b)
  end
  -- -- difference without overflow flag
  -- return uint32.from_raw(a.value - b.value)
  -- difference with overflow flag
  local diff = a.value - b.value
  return uint32.from_raw(diff, a.value >= 0 and b.value < 0 or sgn(a.value) == sgn(b.value) and a.value < b.value) -- todo test thoroughly
 end,

 __mul = function (a, b)
  if type(a) == "number" then
   a = uint32(a)
  elseif type(b) == "number" then
   b = uint32(b)
  end

 end

 __concat = function (a, b)
  if (getmetatable(a) == uint32) a = a:__tostring()
  if (getmetatable(b) == uint32) b = b:__tostring()
  return a .. b
 end,

 set_raw = function(u, val)
  u.value = val
  return u
 end,

 from_raw = function(val, overflow)
  return uint32(0, overflow):set_raw(val)
 end,

},{

 __call=function(t, val, overflow)
  if getmetatable(val) == uint32 then
   val = val.value
  else
   val = lshr(val, 16)
  end
  return setmetatable({ value = val, overflow = overflow }, t)
 end

})
uint32.__index = uint32

local function uint32_number_to_value(n)
 return lshr(n, 16)
end

function uint32:get_raw()
 return self.value
end

function uint32:set_raw(x)
 if self.value ~= x then
  self.value = x
  self.formatted = false
 end
 return self
end

function uint32:set(a)
 return self:set_raw(a.value)
end

function uint32.create_raw(x)
 local instance = uint32.create()
 if instance.value ~= x then
  instance:set_raw(x)
 end
 return instance
end

function uint32.create_from_uint32(b)
 return uint32.create_raw(b.value)
end

function uint32.create_from_number(n)
 return uint32.create_raw(uint32_number_to_value(n))
end

function uint32.create_from_bytes(a, b, c, d)
 return uint32.create_raw(a >>> 16 | b >>> 8 | c | d << 8)
end

function uint32:set_number(n)
 return self:set_raw(uint32_number_to_value(n))
end

function uint32:multiply_raw(y)
 local x = self.value
 if x < y then x, y = y, x end
 local acc = 0

 for i = y, 0x0000.0001, -0x0000.0001 do
  acc = acc + x
 end
 self:set_raw(acc)
 return self
end

function uint32:multiply(b)
 return self:multiply_raw(b.value)
end

function uint32:multiply_number(n)
 return self:multiply_raw(uint32_number_to_value(n))
end

local function decimal_digits_add_in_place(a, b)
 local carry = 0
 local i = 1
 local digits = max(#a, #b)
 while i <= digits or carry > 0 do
  local left = a[i]
  local right = b[i]
  if left == nil then left = 0 end
  if right == nil then right = 0 end
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
 local value = self.value

 -- find highest bit
 local max_index = 0
 local v = value
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
  if mask & value ~= 0 then bit = true end

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

function uint32:to_string(raw)
 if raw == true then
  return tostr(self.value, true)
 else
  -- cache format_decimal result
  if self.formatted ~= true then
   self.str = self:format_decimal()
   self.formatted = true
  end
  return self.str
 end
end

function uint32:to_bytes()
 local value = self.value
 return
  0xff & value << 16,
  0xff & value << 8,
  0xff & value,
  0xff & value >>> 8,
end

function number_to_bytes(value)
 return {
  0xff & value << 16,
  0xff & value << 8,
  0xff & value,
  0xff & value >>> 8,
 }
end

function bytes_to_number(bytes)
 return
  bytes[1] >>> 16 |
  bytes[2] >>> 8 |
  bytes[3] |
  bytes[4] << 8
end

