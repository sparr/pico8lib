pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the tables module
-- by sparr

-- to run the tests use `pico8 -x tests/test_tables.p8`

-- includes required for testing
#include ../class.p8
#include ../log.p8
#include ../functions.p8
#include ../strings.p8
#include ../tables.p8
#include ../test.p8

local suite = TestSuite("tables.p8")


local Get = TestCase("get")

function Get:test_get_hit ()
 self:assert_equal(get({5,6,7},1),5)
end

function Get:test_get_hit_default ()
 self:assert_equal(get({5,6,7},1,9),5)
end

function Get:test_get_miss ()
 self:assert_nil(get({5,6,7},4))
end

function Get:test_get_miss_default ()
 self:assert_equal(get({5,6,7},4,9),9)
end

function Get:test_get_miss_default ()
 self:assert_equal(get({5,6,7},4,9),9)
end

suite:add_test_case(Get)


local Add_ = TestCase("add_")

function Add_:test_typical ()
 local t = {1,2,3}
 local l = #t
 add_(t,9)
 self:assert_equal(t[4],9)
 self:assert_equal(#t,l+1)
end

function Add_:test_empty_table ()
 local t = {}
 local l = #t
 add_(t,9)
 self:assert_equal(t[1],9)
 self:assert_equal(#t,l+1)
end

function Add_:test_nonarray_table ()
 local t = {a=1,b=2}
 local l = #t
 add_(t,9)
 self:assert_equal(t[1],9)
 self:assert_equal(#t,l+1)
end

function Add_:test_mixed_table ()
 local t = {a=1,b=2,6,7}
 local l = #t
 add_(t,9)
 self:assert_equal(t[3],9)
 self:assert_equal(#t,l+1)
end

suite:add_test_case(Add_)


local Del_r = TestCase("del_r")

function Del_r:test_typical ()
 local t = {8,7,6,5}
 local l = #t
 del_r(t,7)
 self:assert_true(table_compare(t,{8,5,6}))
 self:assert_equal(#t,l-1)
end

function Del_r:test_missing_value ()
 local t = {8,7,6}
 local l = #t
 del_r(t,4)
 self:assert_true(table_compare(t,{8,7,6}))
 self:assert_equal(#t,l)
end

function Del_r:test_empty_table ()
 local t = {}
 local l = #t
 del_r(t,2)
 self:assert_true(table_compare(t,{}))
 self:assert_equal(#t,l)
end

suite:add_test_case(Del_r)


local Deli_r = TestCase("deli_r")

function Deli_r:test_typical ()
 local t = {8,7,6,5}
 local l = #t
 deli_r(t,2)
 self:assert_true(table_compare(t,{8,5,6}))
 self:assert_equal(#t,l-1)
end

function Deli_r:test_missing_index ()
 local t = {8,7,6,5}
 local l = #t
 deli_r(t,5)
 self:assert_true(table_compare(t,{8,7,6,5}))
 self:assert_equal(#t,l)
end

function Deli_r:test_empty_table ()
 local t = {}
 local l = #t
 del_r(t,2)
 self:assert_true(table_compare(t,{}))
 self:assert_equal(#t,l)
end

suite:add_test_case(Deli_r)


local Shift = TestCase("shift")

function Shift:test_typical ()
 local t = {8,7,6,5}
 local l = #t
 local r = shift(t)
 self:assert_true(table_compare(t,{7,6,5}))
 self:assert_equal(r,8)
 self:assert_equal(#t,l-1)
end

function Shift:test_empty_table ()
 local t = {}
 local l = #t
 local r = shift(t)
 self:assert_true(table_compare(t,{}))
 self:assert_nil(r)
 self:assert_equal(#t,l)
end

suite:add_test_case(Shift)


local Unshift = TestCase("unshift")

function Unshift:test_typical ()
 local t = {8,7,6,5}
 local l = #t
 unshift(t,9)
 self:assert_true(table_compare(t,{9,8,7,6,5}))
 self:assert_equal(#t,l+1)
end

function Unshift:test_empty_table ()
 local t = {}
 local l = #t
 unshift(t,9)
 self:assert_true(table_compare(t,{9}))
 self:assert_equal(#t,l+1)
end

function Unshift:test_nil_value ()
 local t = {8,7,6,5}
 local l = #t
 unshift(t,nil)
 self:assert_true(table_compare(t,{nil,8,7,6,5}))
 self:assert_equal(#t,l+1)
end

suite:add_test_case(Unshift)


run_suites{suite}
