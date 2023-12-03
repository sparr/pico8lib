pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the graphics module
-- by sparr

-- to run the tests use `pico8 -x tests/test_graphics.p8`

-- includes required for testing
#include ../class.p8
#include ../log.p8
#include ../functions.p8
#include ../strings.p8
#include ../tables.p8
#include ../test.p8

-- file being tested
#include ../graphics.p8

local function check_pixels(test, x, y, pixelstrings)
 for i=x,x+#pixelstrings[1]-1 do
  for j=y,y+#pixelstrings-1 do
   c = pget( i, j )
   e = tonum( "0x" .. pixelstrings[j-y+1][i-x+1] )
   test:assert_equal( c, e, "color at " .. tostr(i) .. "," .. tostr(j) .. " is " .. tostr(c) .. ", expected " .. tostr(e) )
  end
 end
end

local function reset()
   cls()
   pal()
end

local suite = TestSuite("graphics.p8")

-- testing the test capabilities
local Meta = TestCase("meta", reset)

function Meta:test_check_pixels ()
 pset(1,1,4)
 pset(2,3,7)
 check_pixels(self, 0,0,{
  "0000",
  "0400",
  "0000",
  "0070",
  "0000",
 })
end

suite:add_test_case(Meta)


-- Line functions
local Line = TestCase("line", reset)

function Line:test_line__diagonal ()
 line_(1,1,5,7,7)
 check_pixels(self, 0,0,{
  "00000000",
  "07000000",
  "00700000",
  "00700000",
  "00070000",
  "00007000",
  "00007000",
  "00000700",
  "00000000",
 })
end

function Line:test_line__horizontal ()
 line_(3,72,115,72,7)
 check_pixels(self, 2,71,{
  "00000000",
  "07777777",
  "00000000",
 })
 check_pixels(self, 109,71,{
  "00000000",
  "77777770",
  "00000000",
 })
end

function Line:test_line__vertical ()
 line_(19,3,19,91,7)
 check_pixels(self, 18,2,{
  "000",
  "070",
  "070",
  "070",
  "070",
  "070",
  "070",
  "070",
 })
 check_pixels(self, 18,85,{
  "070",
  "070",
  "070",
  "070",
  "070",
  "070",
  "070",
  "000",
 })
end

function Line:test_line_fat ()
 line_fat(1,1,5,7,2,3,7)
 check_pixels(self, 0,0,{
  "00000000",
  "07700000",
  "07770000",
  "07770000",
  "00777000",
  "00777700",
  "00077700",
  "00007770",
  "00007770",
  "00000770",
  "00000000",
 })
end

function Line:test_line_func ()
 expected = {
  {1,1,7,1},
  {2,2,7,2},
  {2,3,7,3},
  {3,4,7,4},
  {4,5,7,5},
  {4,6,7,6},
  {5,7,7,7},
 }
 result = {}
 line_func(1,1,5,7,function (x, y, c, p) result[#result+1] = {x,y,c,p} end,7)
 for y,row in pairs(result) do
  for x,val in pairs(row) do
   self:assert_equal(expected[y][x], val)
  end
 end
end

suite:add_test_case(Line)


-- Sprite functions
local Sprite = TestCase("sprite", reset)

function Sprite:test_spr4fast ()
 spr4_fast(3,1,1)
 check_pixels(self, 0,0,{
  "000000",
  "008880",
  "080770",
  "077660",
  "066550",
  "000000",
 })
end

function Sprite:test_spr4 ()
 spr4(3,1,1)
 check_pixels(self, 0,0,{
  "000000",
  "008880",
  "080770",
  "077660",
  "066550",
  "000000",
 })
end

function Sprite:test_spr4_shrink ()
 spr4(3,1,1,2,2)
 check_pixels(self, 0,0,{
  "0000",
  "0070",
  "0650",
  "0000",
 })
end

function Sprite:test_spr4_expand ()
 spr4(3,1,1,6,8)
 check_pixels(self, 0,0,{
  "00000000",
  "00088880",
  "00088880",
  "08807770",
  "08807770",
  "07776660",
  "07776660",
  "06665550",
  "06665550",
  "00000000",
 })
end

function Sprite:test_spr4_fliph ()
 spr4(3,1,1,4,4,true)
 check_pixels(self, 0,0,{
  "000000",
  "088800",
  "077080",
  "066770",
  "055660",
  "000000",
 })
end

function Sprite:test_spr4_flipv ()
 spr4(3,1,1,4,4,false,true)
 check_pixels(self, 0,0,{
  "000000",
  "066550",
  "077660",
  "080770",
  "008880",
  "000000",
 })
end

suite:add_test_case(Sprite)


-- Circle functions
local Circle = TestCase("circle", reset)

function Circle:test_circ_even_1 ()
 circ_even(1,1,1,1,7)
 check_pixels(self, 0,0,{
  "0000",
  "0770",
  "0770",
  "0000",
 })
end

function Circle:test_circ_even_2 ()
 circ_even(1,1,1,2,7)
 check_pixels(self, 0,0,{
  "000000",
  "007700",
  "070070",
  "070070",
  "007700",
  "000000",
 })
end

function Circle:test_circ_even_8 ()
 circ_even(1,1,1,8,7)
 check_pixels(self, 0,0,{
  "000000000000000000",
  "000000777777000000",
  "000077000000770000",
  "000700000000007000",
  "007000000000000700",
  "007000000000000700",
  "070000000000000070",
  "070000000000000070",
  "070000000000000070",
  "070000000000000070",
  "070000000000000070",
  "070000000000000070",
  "007000000000000700",
  "007000000000000700",
  "000700000000007000",
  "000077000000770000",
  "000000777777000000",
  "000000000000000000",
 })
end

function Circle:test_circ_even_small_1 ()
 circ_even_small(3,1,1,1,7)
 check_pixels(self, 0,0,{
  "0000",
  "0770",
  "0770",
  "0000",
 })
end

function Circle:test_circ_even_small_2 ()
 circ_even_small(3,1,1,2,7)
 check_pixels(self, 0,0,{
  "000000",
  "007700",
  "070070",
  "070070",
  "007700",
  "000000",
 })
end

function Circle:test_circ_even_small_4 ()
 circ_even_small(3,1,1,4,7)
 check_pixels(self, 0,0,{
  "0000000000",
  "0007777000",
  "0070000700",
  "0700000070",
  "0700000070",
  "0700000070",
  "0700000070",
  "0070000700",
  "0007777000",
  "0000000000",
 })
end

function Circle:test_circfill_even_1 ()
 circfill_even(2,1,1,1,7)
 check_pixels(self, 0,0,{
  "0000",
  "0770",
  "0770",
  "0000",
 })
end

function Circle:test_circfill_even_3 ()
 circfill_even(2,1,1,3,7)
 check_pixels(self, 0,0,{
  "00000000",
  "00777700",
  "07777770",
  "07777770",
  "07777770",
  "07777770",
  "00777700",
  "00000000",
 })
end

function Circle:test_circfill_even_8 ()
 circfill_even(2,1,1,8,7)
 check_pixels(self, 0,0,{
  "000000000000000000",
  "000000777777000000",
  "000077777777770000",
  "000777777777777000",
  "007777777777777700",
  "007777777777777700",
  "077777777777777770",
  "077777777777777770",
  "077777777777777770",
  "077777777777777770",
  "077777777777777770",
  "077777777777777770",
  "007777777777777700",
  "007777777777777700",
  "000777777777777000",
  "000077777777770000",
  "000000777777000000",
  "000000000000000000",
 })
end

function Circle:test_circfill_even_small_1 ()
 circfill_even_small(4,1,1,1,7)
 check_pixels(self, 0,0,{
  "0000",
  "0770",
  "0770",
  "0000",
 })
end

function Circle:test_circfill_even_small_3 ()
 circfill_even_small(4,1,1,3,7)
 check_pixels(self, 0,0,{
  "00000000",
  "00777700",
  "07777770",
  "07777770",
  "07777770",
  "07777770",
  "00777700",
  "00000000",
 })
end

function Circle:test_circfill_even_small_4 ()
 circfill_even_small(4,1,1,4,7)
 check_pixels(self, 0,0,{
  "0000000000",
  "0007777000",
  "0077777700",
  "0777777770",
  "0777777770",
  "0777777770",
  "0777777770",
  "0077777700",
  "0007777000",
  "0000000000",
 })
end

suite:add_test_case(Circle)


run_suites{suite}


-- sprites
-- 0 blank
-- 1 circ_even
-- 2 circfill_even
-- 3 circ_even_small
-- 4 circfill_even_small
__gfx__
0000000000000888000008880044440000444400
0000000000088077000888770433334004333340
0000000000807766008877664302203443322334
0000000008076655088766554321123443211234
0000000008760544087665444321123443211234
0000000080765433887654334302203443322334
0000000087654302876543320433334004333340
0000000087654321876543210044440000444400
