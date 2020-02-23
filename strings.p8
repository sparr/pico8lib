pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib strings library
-- by sparr


------------------------------------------------------------------------
-- unambiguous string serialization of arbitrary objects
-- alternate condensed strings included as comments
local function repr(o)
 local visited_tables = {} -- track visited tables to avoid infinite recursion
 local visited_tables_num = 0
 local visited_functions = {}
 local visited_functions_num = 0
 local function _repr(o)
  if (o == true) return "<true>"
  -- if (o == true) return "t"
  if (o == false) return "<false>"
  -- if (o == false) return "f"
  if (o == nil) return "<nil>"
  -- if (o == nil) return "n"
  if (type(o) == "function") then
   if (visited_functions[o]) return "<function[" .. visited_functions[o] .. "]>"
   -- if (visited_functions[o]) return "<f[" .. visited_functions[o] .. "]>"
   visited_functions_num += 1
   visited_functions[o] = visited_functions_num
   return "<function[" .. visited_functions_num .. "]>"
   -- return "<f[" .. visited_functions_num .. "]>"
  end
  if (type(o) == "string") then
   -- escape "s and \s in the string, and quote it
   es = "\""
   for i=1,#o do
    local c = sub(o,i,i)
    es = es .. (c == '"' or c == "\\" and "\\" or "") .. c
   end
   return es .."\""
  end
  if type(o) == "number" then
   -- fall back on full 0xnnnn.nnnn representation if necessary for accuracy
   local numstr = "" .. o
   return tonum(numstr) == o and numstr or tostr(o,true)
  end
  if (type(o) == "table") then
   local function tablerepr(t)
    if (visited_tables[t]) return "<table[" .. visited_tables[t] .. "]>"
    -- if (visited_tables[t]) return "<t[" .. visited_tables[t] .. "]>"
    visited_tables_num += 1
    visited_tables[t] = visited_tables_num
    local head = "<table[" .. visited_tables_num .. "]{"
    -- local head = "<t[" .. visited_tables_num .. "]{"
    local arraykeys = {}
    local r = head
    for i = 1, #t do
     r = r .. (i == 1 and "" or ",") .. _repr(t[i])
     arraykeys[i] = true
    end
    for k,v in pairs(t) do
     if not arraykeys[k] then
      r = r .. (r == head and "" or ",") .. "[" .. _repr(k) .. "]=" .. _repr(v)
     end
    end
    return r .. "}>"
   end
   return tablerepr(o)
  end
 end
 return _repr(o)
end


------------------------------------------------------------------------
-- replacement tostr() that serializes tables
-- all versions ", ..." can be removed to save tokens if you never use tostr(number,true)
local _tostr = tostr
-- this version respects __tostring and prints array values in order without keys
local function tostr(n, ...)
 if type(n) == "table" then
  local m = getmetatable(n)
  if m and m.__tostring then
   return m.__tostring(n, ...)
  else
   local f, s = {}, "{" -- "[table:{" avoids ambiguity with literal strings that look like tables
   for i = 1, #n do
    s = s .. (i == 1 and '' or ",") .. tostr(n[i])
    f[i] = true
   end
   for k, v in pairs(n) do
    if not f[k] then
     s = s .. (s == "{" and '' or ",") .. tostr(k) .. "=" .. tostr(v) -- mishandles reserved words that require ["key"]
    end
   end
   return s .. "}" -- .. "]" to match less ambiguous alternative above
  end
 end
 return _tostr(n, ...)
end
-- this version prints all keys, in unpredictable order
local function tostr(t, ...)
 if type(n) == "table" then
  local s = "{"
  for k, v in pairs(t) do
   s = s .. (s=="{" and '' or ",") .. tostr(k, ...) .. "=" .. tostr(v, ...) -- mishandles reserved words that require ["key"]
  end
  return s
 end
 return _tostr(t, ...)
end


------------------------------------------------------------------------
-- returns n*32768 as a string
-- 0x0000.0001 is "1", 0x7fff.ffff is "2147483647", and 0x8000.0000 is "-2147483648"
local function int32_to_str(n)
 local sign, out, digit = sgn(n) < 0 and "-" or "", ""
 n = abs(n)
 while n > 0 do
  digit = n % 0x.000a * 256 * 256
  n = n / 10
  out = tostr(digit) .. out
 end
 return sign .. out
end


------------------------------------------------------------------------
-- formats a number as hexadecimal with no 0x prefix or zero padding
-- originally from https://www.lexaloffle.com/bbs/?tid=30910
local function hex_unpadded(v) 
  local s, l, r = tostr(v, true), 3, 11
  while sub(s, l, l) == "0" do l += 1 end
  while sub(s, r, r) == "0" do r -= 1 end
  return sub(s, l, r == 7 and 6 or r)
end
-- this version optionally prints minus prefix instead of twos complement negative numbers
local function hex_unpadded(v, n)
  if (v<0 and n) n, v = 1, abs(v)
  local s, l, r = tostr(v, true), 3, 11
  while sub(s, l, l) == "0" do l += 1 end
  while sub(s, r, r) == "0" do r -= 1 end
  return (v and "-" or "") .. sub(s, l, r == 7 and 6 or r)
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
  if char == "\\" and not esc then
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


------------------------------------------------------------------------
-- replace fnd with rep in str
-- 58 tokens
-- originally from https://www.lexaloffle.com/bbs/?pid=72818
-- "yes. please use it!" - shiftalow [2020-02-07 02:19]
local function replace(str, fnd, rep)
 local out = ''
 while #str > 0 do
  local tmp = sub(str, 1, #fnd)
  out = out .. (tmp ~= fnd and sub(str, 1, 1) or rep or '') -- final or is optional if rep is mandatory
  str = sub(str, tmp == fnd and 1 + #fnd or 2)
 end
 return out
end
-- 66 tokens, 5% faster than 58 token implementation
local function replace(str, fnd, rep)
 local out, i = '', 1
 while i < #str - #fnd + 2 do
  local tmp = sub(str, i, i + #fnd - 1)
  if tmp == fnd then
   out = out .. (rep or '') -- "( or '')" is optional if rep is mandatory
   i += #fnd
  else
   out = out .. sub(str, i, i)
   i += 1
  end
 end
 return out
end


------------------------------------------------------------------------
-- check if a char exists in a string
local function char_in_string(c, s)
 for i = 1, #s do
  if (c == sub(s, i, i)) return true
 end
 -- return false -- usually unnecessary
end


------------------------------------------------------------------------
-- wrap a long string to fit on the screen
local function wrap(str)
 local out = ""
 for i=1,#str,32 do
  out = out .. (i>1 and "\n" or "") .. sub(str,i,i+31)
 end
 return out
end
-- this version supports wide glyphs, although they might extend past the end of the screen
-- this version supports an optional max width
local function wrap(str, m)
 local out, w, m = "", 0, m or 32
 for i=1,#str do
  local char = sub(str,i,i)
  local cw = char > "\127" and 2 or 1
  w += cw
  if w > m then
   out = out .. "\n"
   w = cw
  end
  out = out .. char
 end
 return out
end


------------------------------------------------------------------------
-- split a string on a delimiter, return a list of strings
-- split("abc,def,",",") returns {"abc","def",""}
local function split(str, delim)
 local out, pos = {}, 0
 for i=1, #str do
  if sub(str, i, i) == delim then
   add(out, sub(str, pos, i - 1))
   pos = i + 1
  end
 end
 add(out, sub(str, pos))
 return out
end

-- split a string on multiple delimiters, return an n-dimensional array of strings
-- splitd(",a,b;c,d|e,f;","|",";",",") returns {{{"","a","b"},{"c","d"}},{{"e","f"},{}}}
local function splitd(input, delim, ...)
 local out, pos = {}, 0
 if type(input) == "string" then
  for i = 1, #input do
   if sub(input, i, i) == delim then
    add(out, sub(input, pos, i - 1))
    pos = i + 1
   end
  end
  add(out, sub(input, pos))
 end
 if ... then
  for i = 1, #out do
   out[i] = splitd(out[i], ...)
  end
 end
 return out
end


------------------------------------------------------------------------
-- center align string at given x coordinate
-- x defaults to 64 (screen center)
local function str_center(str, x)
 return (x or 64) - #str * 2
end

-- support for wide glyphs
local function str_center(str, x)
 local w = 0
 for i=1,#str do
  w += sub(str,i,i) > "\127" and 4 or 2
 end
 return (x or 64) - w
end


------------------------------------------------------------------------
-- substring function with length instead of end position
-- ssub(a,b) == sub(a,b,b)
-- ssub(a,b,c) == sub(a,b,b+c)
local function ssub(str, idx, len)
 return sub(str, idx, idx + (len or 0))
end