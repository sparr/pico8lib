pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the test module
-- by mindfilleter

-- to run the tests use `pico8 -x tests/test_test.p8`

#include ../class.p8
#include ../log.p8
#include ../functions.p8
#include ../strings.p8
#include ../tables.p8
#include ../test.p8


local suite = TestSuite("test.p8")

-- Assertions test case
local Assertions = TestCase("assertions")

function Assertions:test_assert_nil_pass ()
   self:assert_nil(nil)
end

function Assertions:test_assert_nil_fail ()
   self:assert_throws(function ()
         self:assert_nil(1)
   end, "1 is not nil")
end

function Assertions:test_assert_not_nil_pass ()
   self:assert_not_nil(1)
end

function Assertions:test_assert_not_nil_fail ()
   self:assert_throws(function ()
         self:assert_not_nil(nil)
   end, "[nil] is unexpectedly nil")
end

suite:add_test_case(Assertions)


-- Equality test case
local Equality = TestCase("equality")

function Equality:test_assert_equal_pass ()
   self:assert_equal(1, 1)
end

function Equality:test_assert_equal_fail ()
   self:assert_throws(function ()
         self:assert_equal(1, 2)
   end, "1 ~= 2")
end

function Equality:test_assert_not_equal_pass ()
   self:assert_not_equal(1, 2)
end

function Equality:test_assert_not_equal_fail ()
   self:assert_throws(function ()
         self:assert_not_equal(1, 1)
   end, "1 == 1")
end

suite:add_test_case(Equality)


-- Type test case
local Types = TestCase("types")

function Types:test_assert_boolean_pass ()
   self:assert_boolean(true)
end

function Types:test_assert_boolean_fail ()
   self:assert_throws(function ()
         self:assert_boolean(nil)
   end, "nil is not a boolean")
end

function Types:test_assert_number_pass ()
   self:assert_number(1)
end

function Types:test_assert_number_fail ()
   self:assert_throws(function ()
         self:assert_number("hello")
   end, 'hello is not a number')
end

function Types:test_assert_string_pass ()
   self:assert_string("hello")
end

function Types:test_assert_string_fail ()
   self:assert_throws(function ()
         self:assert_string(nil)
   end, "nil is not a string")
end

suite:add_test_case(Types)


-- Error handling test case
local ErrorHandling = TestCase("error_handling")

function ErrorHandling:test_assert_throws_pass ()
   self:assert_throws(function ()
         assert("oops!" == nil, "oops!")
   end, "oops!")
end

suite:add_test_case(ErrorHandling)


-- Test suite test case
local TestSuiteTest = TestCase("test_suite")

function TestSuiteTest:test_report_counts ()
   local test_suite = TestSuite("suite")
   local TestSuiteTestCase = TestCase("testsuitetest")
   function TestSuiteTestCase:test_assert_nil_pass ()
      self:assert_nil(nil)
   end
   function TestSuiteTestCase:test_assert_nil_fail ()
      self:assert_nil(1)
   end
   test_suite:add_test_case(TestSuiteTestCase)
   test_suite:run(true) -- quiet
   local report = test_suite:make_run_report()
   self:assert_equal(report.tests_run, 2)
   self:assert_equal(report.tests_failed, 1)
end

suite:add_test_case(TestSuiteTest)


run_suites{suite}
