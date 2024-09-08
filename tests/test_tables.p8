pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the tables module
-- by sparr

-- to run the tests use `pico8 -x tests/test_tables.p8`

-- includes required for testing
#include ../pico8lib/class.lua
#include ../pico8lib/log.lua
#include ../pico8lib/functions.lua
#include ../pico8lib/strings.lua
#include ../pico8lib/tables.lua
#include ../pico8lib/test.lua

local suite = TestSuite("tables.p8")


local Get = suite:new_test_case("get")

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


local Add_ = suite:new_test_case("add_")

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


local Del_r = suite:new_test_case("del_r")

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


local Deli_r = suite:new_test_case("deli_r")

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


local Shift = suite:new_test_case("shift")

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


local Unshift = suite:new_test_case("unshift")

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


local sortable_tables = {
 {{},{}},
 {{0},{0}},
 {{1},{1}},
 {{-1},{-1}},
 {{2,0,-1,1,-2},{-2,-1,0,1,2}},
 {{"a"},{"a"}},
 {{"asdf"},{"asdf"}},
 {{"b","e","a","d","c"},{"a","b","c","d","e"}},
}

local Reverse = suite:new_test_case("reverse")

function Reverse:test_reverse ()
 local reversable_tables = {
  {{},{}},
  {{0},{0}},
  {{"a"},{"a"}},
  {{'a',1,'asdf',-1},{-1,'asdf',1,'a'}},
 }
 for _,case in ipairs(reversable_tables) do
  local a = table_copy(case[1])
  reverse(a)
  self:assert_true(table_compare(a,case[2]),"reverse("..tostr(a)..") != "..tostr(case[2]))
 end
end


local Sort = suite:new_test_case("sort")

function Sort:test_sort_slow ()
 for _,case in ipairs(sortable_tables) do
  local a = table_copy(case[1])
  sort_slow(a)
  self:assert_true(table_compare(a,case[2]),tostr(a).." != "..tostr(case[2]))
 end
end

function Sort:test_sort_slow_func ()
 for _,case in ipairs(sortable_tables) do
  local a = table_copy(case[1])
  sort_slow_func(a, function (i,j) return i<j end)
  self:assert_true(table_compare(a,case[2]),tostr(a).." != "..tostr(case[2]))
 end
end

function Sort:test_sort_slow_reverse ()
 for _,case in ipairs(sortable_tables) do
  local a = table_copy(case[1])
  sort_slow_reverse(a)
  reverse(a)
  self:assert_true(table_compare(a,case[2]),tostr(a).." != "..tostr(case[2]))
 end
end

function Sort:test_sort_quick ()
 for _,case in ipairs(sortable_tables) do
  local a = table_copy(case[1])
  sort_quick(a)
  self:assert_true(table_compare(a,case[2]),tostr(a).." != "..tostr(case[2]))
 end
end


run_suites{suite}
