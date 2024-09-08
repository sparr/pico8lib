pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the memory module
-- by sparr

-- to run the tests use `pico8 -x tests/test_memory.p8`

#include ../pico8lib/class.lua
#include ../pico8lib/log.lua
#include ../pico8lib/functions.lua
#include ../pico8lib/strings.lua
#include ../pico8lib/tables.lua
#include ../pico8lib/test.lua

#include ../pico8lib/memory.lua


local suite = TestSuite("memory.p8")

-- MemCpy functions
local MemCpy = TestCase("memcpy")

function MemCpy:test_assert_memcpy4_copies ()
 memset(0x4300, 0, 0x40)
 memcpy4(0x4300, 0x5F00, 0x40)
 for i = 0, 0x3F, 4 do
  self:assert_equal($(0x4300+i), $(0x5F00+i))
 end
end

function MemCpy:test_assert_memcpy_copies ()
 memset(0x4300, 0, 0x40)
 memcpy(0x4301, 0x5F01, 0x3E)
 for i = 1, 0x3E do
  self:assert_equal(@(0x4300+i), @(0x5F00+i))
 end
 -- first and last byte should remain unchanged
 self:assert_equal(@(0x4300+0x00), 0)
 self:assert_equal(@(0x4300+0x3F), 0)
end

suite:add_test_case(MemCpy)


-- MemCmp functions
local MemCmp = TestCase("memcmp")

function MemCmp:test_assert_memcmp4_compares ()
 memset(0x4300, 0, 0x40)
 _memcpy(0x4300, 0x5F00, 0x40)
 self:assert_true(memcmp4(0x4300,0x5F00, 0x40))
 self:assert_false(memcmp4(0x4300,0x4400, 0x40))
end

function MemCmp:test_assert_memcmp_compares ()
 memset(0x4300,0,0x40)
 _memcpy(0x4301,0x5F01,0x3E)
 self:assert_true(memcmp(0x4301, 0x5F01, 0x3E))
 self:assert_false(memcmp(0x4300, 0x5F00, 0x40))
end

suite:add_test_case(MemCmp)


run_suites{suite}
