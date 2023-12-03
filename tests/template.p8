pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the [NAME] module
-- by sparr

-- to run the tests use `pico8 -x tests/test_[NAME].p8`

-- includes required for testing
#include ../class.p8
#include ../log.p8
#include ../functions.p8
#include ../strings.p8
#include ../tables.p8
#include ../test.p8

-- file being tested
#include ../NAME.p8

local function setup() {
}

local suite = TestSuite("[NAME].p8")

-- TestCase1 test case
local TestCase1 = TestCase("testcase1", setup)

function TestCase1:test_assert_pass ()
 self:assert_nil(nil)
end

function TestCase1:test_assert_fail ()
 self:assert_throws(function ()
  self:assert_nil(1)
 end, "1 is not nil")
end

suite:add_test_case(TestCase1)


run_suites{suite}
