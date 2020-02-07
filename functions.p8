pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib functions library
-- by sparr

------------------------------------------------------------------------
-- create a memoized version of a function
-- originally from https://www.lua.org/gems/
local function memoize (f)
 local mem = {}
 setmetatable(mem, {__mode = "kv"})
 return function (x)
  local r = mem[x]
  if r == nil then
   r = f(x)
   mem[x] = r
  end
  return r
 end
end

------------------------------------------------------------------------
-- unpack list to multiple function parameters or return values
-- example: a,b,c = unpack({1,2,3})
local function unpack (arr)
 local function args(k, ...)
  if (k > 0) return args(k - 1, arr[k], ...)
   return ...
  end
  return args(#arr)
 end
 -- i,j are optional start and end indices
 local function unpack (arr, i, j)
  local n, k = {}, 0
  j = j or #arr
  for i = i or 1, j do
   k = k + 1
   n[k] = arr[i]
  end
  local function args(k, ...)
   if k > 0 then
    return args(k - 1, n[k], ...)
   end
   return ...
  end
  return args(k)
 end
 
------------------------------------------------------------------------
-- try/catch/finally implemented with coroutine return codes
-- from https://www.lexaloffle.com/bbs/?pid=72820
-- "enjoy, and if you like it feel free to kick a buck to my patreon."
-- https://www.patreon.com/sharkhugseniko
-- example:
--  try(
--   function()
--    print("good")
--    print("bad" .. nil)
--   end,
--   function(e)
--    print("an error occurred:\n" .. e)
--   end,
--   function()
--    print("finally")
--   end
--  )
local function try(t, c, f)
 local co = cocreate(t)
 local s, m = true
 while s and costatus(co) ~= "dead" do
  s, m = coresume(co)
  if not s then
   c(m)
  end
 end
 if f then
  f()
 end
end
