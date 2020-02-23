pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib json library
-- by sparr

local char_in_string -- from strings.p8

-- based on https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
-- "tylerneylon commented on sep 1, 2015 [...] yes, please use it. i put this in the public domain."

-- error checking is available but commented out, useful for debugging bad hand-crafted json

local json
json = setmetatable({

  null = {}, -- to uniquely identify json null values

  table_delims = { ['{']="}", ['[']="]" },

  -- populate json.vals with keys that should be used to replace literal strings in the json
  -- json.vals[foo=bar] will result in "foo" in the json being replaced with the value bar
  vals = {},

  skip_delim = function(str, pos, delim) -- , err_if_missing)
   pos = json.skip_whitespace(str, pos) -- only needed for unminified json
   if sub(str, pos, pos) != delim then
    -- if(err_if_missing) assert('delimiter missing')
    return pos,false
   end
   return pos + 1,true
  end,

  skip_whitespace = function(str, pos) -- only needed for unminified json
   while char_in_string(sub(str, pos, pos), " \t\n\r") do
    pos += 1
   end
   return pos
  end,

 },{
 __call = function(t, str, pos, end_delim)
  pos = pos or 1
  -- if(pos>#str) assert('reached unexpected end of input.')
  local char = sub(str, pos, pos)
  if table_delims[char] then
   local tbl, key = {}, true
   -- local delim_found = true
   pos += 1
   while true do
    key, pos = t(str, pos, json.table_delims[char])
    if (key == nil) return tbl, pos
    -- if not delim_found then assert('comma missing between table items.') end
    if char == "{" then
     pos = json.skip_delim(str, pos, ':') -- , true) -- -> error if missing.
     tbl[key], pos = t(str, pos)
    else
     -- tbl[#tbl + 1] = key -- faster, more tokens
     add(tbl, key)
    end
    pos, delim_found = json.skip_delim(str, pos, ',')
   end
  elseif char == '"' then
   -- parse a string
   -- lacks support for escape codes, see gist link above for escape support
   local ipos = pos + 1
   -- if(pos>#str) assert('end of input found while parsing string.')
   repeat
    pos +=1
   until sub(str, pos, pos)=='"'
   local val = sub(str, ipos, pos - 1)
   return json.vals[val] or val, pos + 1
  elseif tonum(char .. "0") then
   -- parse a number.
   local ipos = pos
   repeat
    pos += 1
    -- if(pos>#str) assert('end of input found while parsing string.')
   until not char_in_string(sub(str, pos, pos), "-xb0123456789abcdef.") -- support base 10, 16, and 2 numbers
   -- until not tonum(sub(str, pos, pos) .. "0") -- base 10 only 
   return tonum(sub(str, ipos, pos - 1)), pos
  elseif char == end_delim then
   -- end of an object or array.
   return nil, pos+1
  elseif char_in_string(char," \t\n\r") then -- only needed for unminified json
   -- skip whitespace
   pos = json.skip_whitespace(str, pos)
   return t(str, pos, end_delim)
  else  -- parse true, false, null
   for lit_str, lit_val in pairs(json.literals) do
    local lit_end = pos + #lit_str - 1
    if (sub(str, pos, lit_end) == lit_str) return lit_val, lit_end + 1
   end
   -- assert('invalid json token')
  end
 end

})

json.literals = { ['true']=true, ['false']=false, ['null']=json.null }


------------------------------------------------------------------------
-- tests
assert(json'123' == 123)
assert(json'1.2' == 1.2)
assert(json'0xa.a' == 10+5/8)
assert(json'0b1010' == 10)
assert(json'"abc"' == "abc")
assert(json'null' == json.null)
assert(json'true' == true)
assert(json'false' == false)
assert(json'{"abc":[1,2,{"def":[1,false]}]}'.abc[3].def[2] == false)
assert(json[[
 { "1 a" : 1 }
 ]]['1 a'] == 1)
