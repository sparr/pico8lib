pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the math module
-- by sparr

-- to run the tests use `pico8 -x tests/test_math.p8`

#include ../pico8lib/class.lua
#include ../pico8lib/strings.lua
#include ../pico8lib/log.lua
#include ../pico8lib/functions.lua
#include ../pico8lib/tables.lua
#include ../pico8lib/test.lua

#include ../pico8lib/math.lua


local suite = TestSuite("math.p8")

-- Tables
-- local Tables = TestCase("tables")

-- pico8 does not currently have a reliable way to detect overflow in * or ^
-- function Tables:test_power_overflow ()
-- end

-- suite:add_test_case(Tables)


-- Overflow checks
-- local Overflow = TestCase("overflow")

-- this almost works, but has problems around a or b == -32768 and t==0.5
-- function Overflow:test_testmul32k ()
--  for _,v in ipairs({
--   {0,0,true},
--   {1,1,true},
--   {1,0x7fff.ffff,true},
--   {0x0.0001,0x7fff.ffff,true},
--   {2,16384,false},
--   {182,182,false},
--  })
--  do
--   self:assert_equal(testmul32k(v[1],v[2]), v[3], tostr(v[1],true) .. "(" .. tostr(v[1]) .. ") * " .. tostr(v[2],true) .. "(" .. tostr(v[2]) .. ") = " .. tostr(v[1]*v[2],true) .. " overflow should not be " .. tostr(v[3]))
--   self:assert_equal(testmul32k(-v[1],-v[2]), v[3], tostr(-v[1],true) .. "(" .. tostr(-v[1]) .. ") * " .. tostr(-v[2],true) .. "(" .. tostr(-v[2]) .. ") = " .. tostr(-v[1]*-v[2],true) .. " overflow should not be " .. tostr(v[3]))
--  end
-- end

-- suite:add_test_case(Overflow)


-- Rational (fraction) functions
local Rational = TestCase("rational")

function Rational:test_gcd ()
 for _,v in ipairs({
  {1,1,1},
  {1,2,1},
  {2,3,1},
  {2,4,2},
  {12,30,6},
  {32736,31713,1023},
 })
 do
  self:assert_equal(gcd_recursive(v[1],v[2]), v[3])
  self:assert_equal(gcd_recursive(v[2],v[1]), v[3])
  self:assert_equal(gcd(v[1],v[2]), v[3])
  self:assert_equal(gcd(v[2],v[1]), v[3])
 end
end

function Rational:test_lcm ()
 for _,v in ipairs({
  {1,1,1},
  {1,2,2},
  {2,3,6},
  {4,6,12},
  {180,181,32580},
  {16383,10922,32766},
 })
 do
  self:assert_equal(lcm(v[1],v[2]), v[3])
  self:assert_equal(lcm(v[2],v[1]), v[3])
 end
end

suite:add_test_case(Rational)


-- Nth Root functions
local Nthroot = TestCase("nthroot")

function Nthroot:test_nthroot ()
 for _,v in ipairs({
  {1,1,1},
  {1,2,2},
  {2,1,1},
  {2,4,2},
  {3,8,2},
  {2,32767,181.0166},
  {12,32767,2.3784},
  {3/2,27,9},
  -- todo test cases that explore the worst case of nthroot_fast
 })
 do
  self:assert_almost_equal(nthroot(v[1],v[2]), v[3], .0001)
  self:assert_almost_equal(nthroot_short(v[1],v[2]), v[3], .0001)
  self:assert_almost_equal(nthroot_fast(v[1],v[2]), v[3], .0001)
 end
end

suite:add_test_case(Nthroot)


-- Distancefunctions
local Distance = TestCase("distance")

function Distance:test_dist_exact ()
 for _,v in ipairs({
  {0,0,0},
  {1,1,sqrt(2)},
  {3,4,5},
  {44,117,125},
 })
 do
  self:assert_equal(dist(v[1],v[2]), v[3])
  self:assert_equal(dist(v[2],v[1]), v[3])
 end
end

function Distance:test_dist_naive_exact ()
 for _,v in ipairs({
  {0,0,0},
  {1,1,sqrt(2)},
  {3,4,5},
  {44,117,125},
 })
 do
  self:assert_equal(dist_naive(v[1],v[2]), v[3])
  self:assert_equal(dist_naive(v[2],v[1]), v[3])
 end
end

function Distance:test_dist_trig_approx()
 for _,v in ipairs({
  {0,0,0},
  {1,1,sqrt(2)},
  {3,4,5},
  {44,117,125},
  {119,120,169},
  {0,32767,32767},
  {23170,23170,32767.32824},
 })
 do
  self:assert_almost_equal(dist_trig(v[1],v[2]), v[3], v[1]/0x4000+v[2]/0x4000)
  if (v[2] ~= v[1]) self:assert_almost_equal(dist_trig(v[2],v[1]), v[3], v[1]/0x1000+v[2]/0x4000)
 end
end

function Distance:test_dist_squared()
 for _,v in ipairs({
  {0,0,0},
  {1,1,2},
  {3,4,25},
  {44,117,15625},
 })
 do
  self:assert_equal(dist_squared(v[1],v[2]), v[3])
  self:assert_equal(dist_squared(v[2],v[1]), v[3])
 end
end

suite:add_test_case(Distance)


run_suites{suite}
