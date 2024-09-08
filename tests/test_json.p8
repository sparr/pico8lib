pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the json module
-- by sparr

-- to run the tests use `pico8 -x tests/test_json.p8`

#include ../pico8lib/class.lua
#include ../pico8lib/strings.lua
#include ../pico8lib/log.lua
#include ../pico8lib/functions.lua
#include ../pico8lib/tables.lua
#include ../pico8lib/test.lua

#include ../pico8lib/json.lua


local suite = TestSuite("json.p8")

-- Parse test case
local Parse = TestCase("Parse")

function Parse:test_parse_integer ()
 self:assert_equal(json'123', 123)
end

function Parse:test_parse_decimal ()
 self:assert_equal(json'1.5', 1.5)
end

function Parse:test_parse_hex ()
 self:assert_equal(json'0xa.a', 10+5/8)
end

function Parse:test_parse_binary ()
 self:assert_equal(json'0b1010', 10)
end

function Parse:test_parse_string ()
 self:assert_equal(json'"abc"', "abc")
end

function Parse:test_parse_null ()
 self:assert_equal(json'null', json.null)
end

function Parse:test_parse_true ()
 self:assert_equal(json'true', true)
end

function Parse:test_parse_false ()
 self:assert_equal(json'false', false)
end

function Parse:test_parse_deep ()
 self:assert_equal(json'{"abc":[1,2,{"def":[1,"xyz"]}]}'.abc[3].def[2], "xyz")
end

function Parse:test_parse_multiline ()
 self:assert_equal(json[[
{"1 a":"abc"}
]]["1 a"], "abc")
end

function Parse:test_parse_whitespace ()
 self:assert_equal(json' [ { "a b" : "c d" } ] '[1]["a b"], "c d")
end

suite:add_test_case(Parse)


run_suites{suite}
