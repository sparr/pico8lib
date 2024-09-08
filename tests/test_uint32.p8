pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the uint32 module

-- to run the tests use `pico8 -x tests/test_uint32.p8`

-- includes required for testing
#include ../pico8lib/class.lua
#include ../pico8lib/strings.lua
#include ../pico8lib/log.lua
#include ../pico8lib/functions.lua
#include ../pico8lib/tables.lua
#include ../pico8lib/test.lua

-- file being tested
#include ../pico8lib/uint32.lua


local suite = TestSuite("uint32.p8")

local Construction = TestCase("construction")

local raw_values = {
 { 0, 0 },
 { 1, 0x0000.0001 },
 { 32767, 0x0000.7FFF },
}

function Construction:test_constructor ()
 for _,values in pairs(raw_values) do
  self:assert_equal(uint32(values[1]), uint32.from_raw(values[2]))
 end
end

suite:add_test_case(Construction)

local ToString = TestCase("tostring")

local string_values = {
 { 0, "0" },
 { 0x0000.0001, "1" },
 { 0x0001.0000, "65536" },
 { 0x7FFF.FFFF, "2147483647" },
 { 0x8000.0000, "2147483648" },
 { 0xFFFF.FFFF, "4294967295" },
}

function ToString:test_tostring ()
 for _,values in pairs(string_values) do
  self:assert_equal(uint32.from_raw(values[1]):__tostring(), values[2])
 end
end

suite:add_test_case(ToString)


local Comparison = TestCase("comparison")

local test_values = {
 uint32.zero,
 uint32.one,
 uint32(32767),
 uint32.from_raw(0x0001.0001),
 uint32.from_raw(0x7FFF.0000),
 uint32.from_raw(0x7FFF.FFFF),
 uint32.from_raw(0x8000.0000),
 uint32.maxint,
}

function Comparison:test_equality ()
 for i = 1,#test_values do
  for j = 1,#test_values do
   if i == j then
    self:assert_equal(test_values[i], test_values[j])
   else
    self:assert_not_equal(test_values[i], test_values[j])
   end
  end
 end
end

function Comparison:test_less_than ()
 for i = 1,#test_values do
  for j = 1,#test_values do
   if i < j then
    self:assert_less_than(test_values[i], test_values[j])
   else
    self:assert_greater_than_or_equal(test_values[i], test_values[j])
   end
  end
 end
end

function Comparison:test_less_than_or_equal ()
 for i = 1,#test_values do
  for j = 1,#test_values do
   if i <= j then
    self:assert_less_than_or_equal(test_values[i], test_values[j])
   else
    self:assert_greater_than(test_values[i], test_values[j])
   end
  end
 end
end

suite:add_test_case(Comparison)


local Arithmetic = TestCase("arithmetic")

local test_sums = {
 -- If every test case here is included, a later unrelated test will eventually produce this error:
 -- "attempt to yield across a C-call boundary"
 -- Commenting out some of about half the test cases here makes this error go away.
 -- Commenting out some test cases in other sets (e.g. string_values) also makes this error go away.
 -- Adding an extra `coresume(co)` in the implementation of `try` before it calls `c` delays this error a bit.
 -- Even though the error comes from code that doesn't even read these tables!
 -- Temporarily commenting out tests until a bug report can be made
 { uint32.one, uint32.one, uint32(2), false },
--  { uint32(32767), uint32(32767), uint32.from_raw(0x0000.FFFE), false },
 { uint32.from_raw(0x0001.0001), uint32.from_raw(0x0001.0001), uint32.from_raw(0x0002.0002), false },
 -- { uint32.from_raw(0x7FFF.FFFF), uint32.one, uint32.from_raw(0x8000.0000), false },
 { uint32.from_raw(0x7FFF.FFFF), uint32.from_raw(0x7FFF.FFFF), uint32.from_raw(0xFFFF.FFFE), false },
 { uint32.maxint, uint32.one, uint32.zero, true },
 { uint32.maxint, uint32.maxint, uint32.from_raw(0xFFFF.FFFE), true },
}

function Arithmetic:test_addition ()
 for _,value in pairs(test_values) do
  local sum1 = uint32.zero + value
  local sum2 = value + uint32.zero
  self:assert_equal(sum1, value)
  self:assert_equal(sum2, value)
  self:assert_false(sum1.overflow)
  self:assert_false(sum2.overflow)
 end
 for _,values in pairs(test_sums) do
  local sum1 = values[1] + values[2]
  local sum2 = values[2] + values[1]
  self:assert_equal(sum1, values[3])
  self:assert_equal(sum2, values[3])
  self:assert_equal(sum1.overflow, values[4])
  self:assert_equal(sum2.overflow, values[4])
 end
end

function Arithmetic:test_subtraction ()
 for _,values in pairs(test_sums) do
  local sub1 = values[3] - values[1]
  local sub2 = values[3] - values[2]
  self:assert_equal(sub2, values[1])
  self:assert_equal(sub1, values[2])
  self:assert_equal(sub1.overflow, values[4])
  self:assert_equal(sub2.overflow, values[4])
 end
end

local test_products = {
 { uint32(2), uint32(2), uint32(4), false },
 { uint32(2), uint32(32767), uint32.from_raw(0x0000.FFFE), false },
}

function Arithmetic:test_multiplication ()
 for _,value in pairs(test_values) do
  local product = uint32.zero * value
  self:assert_equal(product, uint32.zero)
  self:assert_false(product.overflow)
 end
 for _,value in pairs(test_values) do
  local product = uint32.one * value
  self:assert_equal(product, value, tostr(uint32.one) .. " * " .. tostr(value) .. " ~= " .. tostr(value) .. ", == " .. tostr(product))
  self:assert_false(product.overflow)
 end
 for _,values in pairs(test_products) do
  local product1 = values[1] * values[2]
  local product2 = values[2] * values[1]
  local expected = values[3]
  self:assert_equal(product1, values[3], tostr(values[1]) .. " * " .. tostr(values[2]) .. " ~= " .. tostr(values[3]) .. ", == " .. tostr(product1))
  self:assert_equal(product2, values[3], tostr(values[2]) .. " * " .. tostr(values[1]) .. " ~= " .. tostr(values[3]) .. ", == " .. tostr(product2))
  self:assert_equal(product1.overflow, values[4])
  self:assert_equal(product2.overflow, values[4])
 end
end

suite:add_test_case(Arithmetic)

run_suites{suite}
