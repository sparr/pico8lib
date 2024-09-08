pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

-- Unit tests for the vector module
-- by sparr

-- to run the tests use `pico8 -x tests/test_vector.p8`

-- includes required for testing
#include ../pico8lib/class.p8
#include ../pico8lib/log.p8
#include ../pico8lib/functions.p8
#include ../pico8lib/strings.p8
#include ../pico8lib/tables.p8
#include ../pico8lib/test.p8

-- file being tested
#include ../pico8lib/vector.p8


local suite = TestSuite("vector.p8")

local Comparison = TestCase("comparison")

function Comparison:test_equality ()
 self:assert_equal(vector{2,3}, vector{2,3})
end

suite:add_test_case(Comparison)


local Arithmetic = TestCase("arithmetic")

function Arithmetic:test_unary_minus ()
 self:assert_equal(vector{2,3}, -vector{-2,-3})
end

function Arithmetic:test_addition ()
 self:assert_equal(vector{2,3} + vector{-1,2}, vector{1,5})
end

function Arithmetic:test_subtraction ()
 self:assert_equal(vector{2,3} - vector{1,2}, vector{1,1})
end

function Arithmetic:test_multiplication_scalar ()
 self:assert_equal(vector{2,3} * 2, vector{4,6})
 self:assert_equal(2 * vector{2,3}, vector{4,6})
end

function Arithmetic:test_multiplication_vector ()
 self:assert_equal(vector{2,3} * vector{-1,2}, 4)
end

function Arithmetic:test_crossproduct ()
 self:assert_equal(vector{2,3}:crossproduct(vector{-1,2}), 7)
end

function Arithmetic:test_division ()
 self:assert_equal(vector{2,6} / 2, vector{1,3})
end

suite:add_test_case(Arithmetic)


local Magnitude = TestCase("magnitude")

function Magnitude:test_length_operator ()
 self:assert_equal(#vector{3,4}, 5)
end

function Magnitude:test_mag_func ()
 self:assert_equal(vector{3,4}:mag(), 5)
end

function Magnitude:test_magsqr_func ()
 self:assert_equal(vector{3,4}:magsqr(), 25)
end

suite:add_test_case(Magnitude)


local Representation = TestCase("representation")

function Representation:test_str ()
 self:assert_equal(vector{2,-1}:__tostring(), "[vector:2,-1]")
end

suite:add_test_case(Representation)


local Angle = TestCase("angle")

function Angle:test_east ()
 self:assert_equal(vector{1,0}:angle(), 0)
end

function Angle:test_southeast ()
 self:assert_equal(vector{2,2}:angle(), 1/8)
end

function Angle:test_west ()
 self:assert_equal(vector{-3,0}:angle(), 1/2)
end

suite:add_test_case(Angle)


local Normalize = TestCase("normalize")

function Normalize:test_normalize ()
 self:assert_almost_equal(vector{3,4}:normalize(), vector{3/5,4/5}, 0x.0001)
end

suite:add_test_case(Normalize)


local Contained = TestCase("contained")

function Contained:test_contained ()
 self:assert_true(vector{0,0}:contained(vector{0,0},vector{2,2}))
 self:assert_true(vector{1,1}:contained(vector{0,0},vector{2,2}))
 self:assert_true(vector{2,2}:contained(vector{0,0},vector{2,2}))
end

function Contained:test_not_contained ()
 self:assert_false(vector{-1,1}:contained(vector{0,0},vector{2,2}))
 self:assert_false(vector{3,1}:contained(vector{0,0},vector{2,2}))
 self:assert_false(vector{1,-1}:contained(vector{0,0},vector{2,2}))
 self:assert_false(vector{1,3}:contained(vector{0,0},vector{2,2}))
end

suite:add_test_case(Normalize)


local Rotate = TestCase("rotate")

function Rotate:test_rotate_90 ()
 self:assert_equal(vector{2,1}:rotate_90(), vector{-1,2})
end

function Rotate:test_rotate_180 ()
 self:assert_equal(vector{2,1}:rotate_180(), vector{-2,-1})
end

function Rotate:test_rotate_270 ()
 self:assert_equal(vector{2,1}:rotate_270(), vector{1,-2})
end

function Rotate:test_rotate_degrees_30 ()
 self:assert_almost_equal(#(vector{sqrt(3)/2,-0.5}:rotate_degrees(30) - vector{1,0}), 0, 0x.0001)
end

function Rotate:test_rotate_fraction ()
 self:assert_almost_equal(#(vector{sqrt(3)/2,-0.5}:rotate(5/12) - vector{-0.5,sqrt(3)/2}), 0, 0x.0001)
end

suite:add_test_case(Rotate)


local Polar = TestCase("polar")

function Polar:test_length ()
 self:assert_almost_equal(#vector.from_polar{r=1,t=7/8}, #vector{sqrt(2)/2,-sqrt(2)/2}, 0x.0003)
end

function Polar:test_radius ()
 self:assert_almost_equal(vector{sqrt(3)/2,-0.5}:to_polar().r, 1, 0x.0002)
end

function Polar:test_theta ()
 self:assert_almost_equal(vector{sqrt(3)/2,-0.5}:to_polar().t, 11/12, 0x.0002)
end

suite:add_test_case(Polar)


run_suites{suite}
