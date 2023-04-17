pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the test module
-- by mindfilleter

-- Depends on pico8lib/[class.p8, log.p8, functions.p8, string.p8]

-- to run the tests use `pico8 -x tests/test_test.p8`

#include ../log.p8
#include ../class.p8
#include ../functions.p8
#include ../strings.p8
#include ../test.p8


local suite = TestSuite("test.p8")

local Assertions = class(TestCase(), {})

function Assertions:__init ()
   TestCase.__init(self, "assertions")
end

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


suite:add_test_case(Assertions())
run_suites{suite}
