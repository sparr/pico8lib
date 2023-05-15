pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the class module
-- by sparr

-- to run the tests use `pico8 -x tests/test_class.p8`

#include ../class.p8
#include ../functions.p8
#include ../log.p8
#include ../strings.p8
#include ../tables.p8
#include ../test.p8

local suite = TestSuite("class.p8")

local Inheritance = TestCase("inheritance")

function Inheritance:test_assert_inheritance_values ()
 local class_parent = class( nil, { a = 1 } )
 local class_child = class(class_parent, { b = 2 } )
 local instance_parent = class_parent()
 local instance_child = class_child()
 self:assert_equal(class_parent.a, 1)
 self:assert_nil(class_parent.b)
 self:assert_equal(instance_parent.a, 1)
 self:assert_nil(instance_parent.b)
 self:assert_equal(class_child.a, 1)
 self:assert_equal(class_child.b, 2)
 self:assert_equal(instance_child.a, 1)
 self:assert_equal(instance_child.b, 2)
 class_parent.a = 3
 self:assert_equal(class_child.a, 3)
 self:assert_equal(instance_child.a, 3)
 self:assert_equal(instance_parent.a, 3)
 class_child.a = 4
 self:assert_equal(instance_parent.a, 3)
 self:assert_equal(instance_child.a, 4)
 instance_parent.a = 5
 self:assert_equal(class_parent.a, 3)
 self:assert_equal(instance_child.a, 4)
 instance_child.a = 6
 self:assert_equal(class_parent.a, 3)
 self:assert_equal(class_child.a, 4)
 class_child.b = 7
 self:assert_equal(instance_child.b, 7)
end

suite:add_test_case(Inheritance)

run_suites{suite}
