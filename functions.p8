pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib functions library
-- by sparr


--- empty function, useful for callbacks and placeholders
local function noop() end


--- raise an error
-- tparam[opt] string error message
local function error(m)
 assert(false, m)
end


--- create a memoized version of a single parameter function
-- originally from https://www.lua.org/gems/
-- @tparam function f the function to memoize
-- @treturn function the memoized function
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


--- try/catch/finally implemented with coroutine return codes
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
-- @tparam function t function to always call first
-- @tparam function c function to call if t raises an error
-- @tparam[opt] function f function to call if t or c succeeds without error
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
