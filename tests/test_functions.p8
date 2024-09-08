pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the functions module
-- by sparr

-- to run the tests use `pico8 -x tests/test_functions.p8`

#include ../pico8lib/class.p8
#include ../pico8lib/log.p8
#include ../pico8lib/functions.p8
#include ../pico8lib/strings.p8
#include ../pico8lib/tables.p8
#include ../pico8lib/test.p8


local suite = TestSuite("functions.p8")

-- Memoize test case
local Memoize = TestCase("memoize")

function Memoize:test_memoize_hit ()
 local canary = 0
 local r
 function f(a)
  canary = canary + 1
  return a + 1
 end
 m = memoize(f)
 self:assert_equal(canary, 0)
 r = m(1)
 self:assert_equal(r, 2)
 self:assert_equal(canary, 1)
 r = m(1)
 self:assert_equal(r, 2)
 self:assert_equal(canary, 1)
end

function Memoize:test_memoize_miss ()
 local canary = 0
 local r
 function f(a)
  canary = canary + 1
  return a + 1
 end
 m = memoize(f)
 self:assert_equal(canary, 0)
 r = m(1)
 self:assert_equal(r, 2)
 self:assert_equal(canary, 1)
 r = m(2)
 self:assert_equal(r, 3)
 self:assert_equal(canary, 2)
end

suite:add_test_case(Memoize)


-- Try test case
local Try = TestCase("try")

function Try:good (t)
 return function ()
  t[1] = true
 end
end

function Try:bad (t)
 return function ()
  t[1] = true
  error()
 end
end

function Try:test_try_success ()
 local t = {}
 local c = {}
 local f = {}
 try(self:good(t), self:bad(c), self:good(f))
 self:assert_equal(t[1], true)
 self:assert_nil(c[1], true)
 self:assert_equal(f[1], true)
end

function Try:test_try_error_in_try ()
 local t = {}
 local c = {}
 local f = {}
 try(self:bad(t), self:good(c), self:good(f))
 self:assert_equal(t[1], true)
 self:assert_equal(c[1], true)
 self:assert_equal(f[1], true)
end

function Try:test_try_error_in_catch ()
 local t = {}
 local c = {}
 local f = {}
 self:assert_throws(function ()
  try(self:bad(t), self:bad(c), self:good(f))
 end, "assertion failed!")
 self:assert_equal(t[1], true)
 self:assert_equal(c[1], true)
 self:assert_nil(f[1])
end

function Try:test_try_error_in_finally ()
 local t = {}
 local c = {}
 local f = {}
 self:assert_throws(function ()
  try(self:good(t), self:good(c), self:bad(f))
 end, "assertion failed!")
 self:assert_equal(t[1], true)
 self:assert_nil(c[1], true)
 self:assert_equal(f[1], true)
end

suite:add_test_case(Try)

run_suites{suite}
