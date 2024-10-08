--- @module functions
--- Function manipulation, creation, and helpers


--- Empty function, useful for callbacks and placeholders
local function noop() end


--- Raise an error with the given message
-- @tparam[opt] string m The error message (string) to output
local function error(m)
 assert(false, m)
end


--- Create a memoized version of a single parameter function
-- @tparam function f the function to memoize
-- @treturn function the memoized function
local function memoize (f)
 -- originally from https://www.lua.org/gems/
 local mem = {}
 -- all keys and values in the mem table should be weak references
 -- https://www.lua.org/pil/17.html
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


--- try/catch/finally implemented using coroutine return codes
-- @tparam function t function to always call first
-- @tparam[opt] function c function to call if t raises an error
-- @tparam[opt] function f function to call if t or c succeeds without error
-- @param ... Additional parameters that will be passed to `t`, `c`, and `f`
-- @treturn bool Did `t` exit without error?
-- @return Error message or successful return value from `t`
local function try(t, c, f, ...)
 -- originally from https://www.lexaloffle.com/bbs/?pid=72820
 -- "enjoy, and if you like it feel free to kick a buck to my patreon."
 -- https://www.patreon.com/sharkhugseniko
 local co = cocreate(t)
 local s, m = true
 -- This loop can be omitted and the contents run just once if `t` cannot contain `yield()`
 while s and costatus(co) ~= "dead" do
  s, m = coresume(co, ...)
  if not s and c then
   c(m, ...)
  end
 end
 if f then
  f(...)
 end
 return s, m
end
