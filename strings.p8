pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib strings library
-- by sparr

------------------------------------------------------------------------
-- replacement tostr() that respects __tostring and can serialize tables
local _tostr=tostr
local function tostr(n, ...)
 if type(n) == "table" then
  local m = getmetatable(n)
  if m and m.__tostring then
   return m.__tostring(n, ...)
  else
   local s, f = "{", {}
   for i = 1, #n do
    s = s .. tostr(n[i]) .. ", "
    f[i] = true
   end
   for k,v in pairs(n) do
    if not f[k] then
     s = s .. tostr(k) .. "=" .. tostr(v) .. ", " -- mishandles reserved words that require ["key"]
    end
   end
   s = sub(s, 1, #s-2) .. "}"
   return s
  end
 end
 return _tostr(n, ...)
end

------------------------------------------------------------------------
-- returns n*32768 as a string
-- 0x0000.0001 is "1", 0x7fff.ffff is "2147483647", and 0x8000.0000 is "-2147483648"
local function int32_to_str(n)
 local sign, out, digit = sgn(n) < 0 and "-" or "" , ""
 n = abs(n)
 while n > 0 do
  digit = n % 0x.000a * 256 * 256
  n = n / 10
  out = tostr(digit) .. out  
 end
 return sign .. out
end

------------------------------------------------------------------------
-- turns "ab2c4de" into "abccdddde"
local function rle_decode(str)
 local out, count = "", ""
 for i = 1, #str do
  local char = sub(str, i, i)
  if tonum(char) then
   count = count .. char
  else
   for j = 1, (tonum(count) or 1) do
    out = out .. char
   end
   count = ""
  end
 end
 return out
end
-- support for escaped digits and backslash as \\1 ... \\9 and \\\
-- turns "a3\\12bc" into "a111bbc"
local function rle_decode(str)
 local out, count, esc = "", ""
 for i = 1, #str do
  local char = sub(str, i, i)
  if char=="\\" and not esc then
   esc = true
  elseif tonum(char) and not esc then
   count = count .. char
  else
   for j = 1, (tonum(count) or 1) do
    out = out .. char
   end
   count=""
  end
 end
 return out
end
