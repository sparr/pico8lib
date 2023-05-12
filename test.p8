pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib unit test library
-- by mindfilleter

-- #include class.p8
-- #include log.p8
-- #include functions.p8
-- #include strings.p8

--- The TestCase class represents a collection of tests to be run for a given context. Subclass TestCase and add functions starting with "test_" then add an instance to a TestSuite instance to run your tests. For an example of how do this, see the `Assertions` test case in `test/test_test.p8`.
local TestCase = class(
   nil,
   {
      name = nil,
      tests_run = 0,
      tests_failed = 0,
   }
)

--- TestCase naming convention: snake_case
function TestCase:__init (name)
   self.name = name
end


--- setup is run before each test function is executed. It exists as a hook to setup state relevant to the test on the TestCase instance. Override this method as needed in your TestCase subclass.
function TestCase:setup ()
   -- NOOP
end

--- teardown is run after each test function is executed. It exists as a hook to reset state relevant to the test on the TestCase instance. Override this method as needed in your TestCase subclass.
function TestCase:teardown ()
   -- NOOP
end

function TestCase:_parse_error_message (e)
   local parts = split(e, ":")
   return sub(parts[#parts], 2)
end

--- Call all of the test functions that start with "test_" and track failures.
function TestCase:run (quiet)
   tests = {}
   for key, val in pairs(self) do
      if type(val) == "function" and starts_with(key, "test_") then
         tests[key] = val
      end
   end
   for test_name, test_func in pairs(tests) do
      try(
         function ()
            test_func(self)
            if not quiet then log_info("PASS: TestCase:" .. self.name .. ":" .. test_name) end
         end,
         function (e)
            self.tests_failed = self.tests_failed + 1
            if not quiet then log_err("FAIL: TestCase:" .. self.name .. ":" .. test_name .. " " .. self:_parse_error_message(e)) end
         end,
         function ()
            self.tests_run = self.tests_run + 1
         end
      )
   end
end


--- Call the function fn and assert that an exception is thrown with
--- the given `expected message`
-- See `test/test_test.p8` for examples of how to use this assertion
-- @param fn A function to be called
-- @param expected_message The exact text of the expected exception
-- @return nil
function TestCase:assert_throws(fn, expected_message)
   local threw = false
   if (expected_message == nil) expected_message = ""
   try(
      fn,
      function (e)
         threw = true
         local err_msg = self:_parse_error_message(e)
         if err_msg ~= expected_message then
            assert(nil, "expected exception '"
                   .. expected_message .. "' but received '" .. err_msg .. "'")
         end
      end,
      nil
   )
   if not threw then
      assert(nil, "expected exception '" .. expected_message .. "' but none was thrown")
   end
end

--- Assert that `any` is nil
-- @param any a value that is expected to be nil
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_nil (any, message)
   assert(any == nil, message or tostr(tostr(any) .. " is not nil"))
end

--- Assert that `any` is not nil
-- @param any a value that is expected to not be nil
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_not_nil (any, message)
   assert(any != nil, message or tostr(any) .. " is unexpectedly nil")
end

--- Assert that `any` is true
-- @param any a value that is expected to be true
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_true (any, message)
   assert(any, message or "unexpectedly false")
end

--- Assert that `any` is false
-- @param any a value that is expected to be false
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_false (any, message)
   assert(not any, message or "unexpectedly true")
end

--- Assert that `a` is equal to `b`
-- @param a the actual object
-- @param b the expected object
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_equal (a, b, message)
   assert(a == b, message or tostr(a) .. " ~= " .. tostr(b))
end

--- Assert that `a` is almost equal to `b`, useful for comparing floating points.
-- @param a the actual floating point value
-- @param b the expected floating poitn value
-- @param tolerance the absolute variance allowed between `a` and `b`
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_almost_equal(a, b, tolerance, message)
   assert(abs(a - b) <= tolerance, message or tostr(a) .. " ~= " .. tostr(b) .. " (tolerance=" .. tolerance .. ")")
end

--- Assert that `a` is not equal to `b`
-- @param a the actual object
-- @param b the undesired object
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_not_equal (a, b, message)
   assert(a ~= b, message or tostr(a) .. " == " .. tostr(b))
end

-- Assert that the table contains the expected key
-- @param tbl the table to check
-- @param key the key to search for in the table
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_in (tbl, key, message)
   assert(not tbl[key] == nil, message or tostr(key) .. " not found in table")
end

-- Assert that the table does not contain the expected key
-- @param tbl the table to check
-- @param key the key to search for in the table
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_not_in (tbl, key, message)
   assert(tbl[key] == nil, message or tostr(key) .. " unexpectedly found in table")
end

--- Assert that `a` is less than `b`
-- @param a the actual value
-- @param b the upper limit
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_less_than (a, b, message)
   assert(a < b, message or tostr(a) .. " >= " .. tostr(b))
end

--- Assert that `a` is less than or equal to `b`
-- @param a the actual value
-- @param b the upper limit
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_less_than_or_equal (a, b, message)
   assert(a <= b, message or tostr(a) .. " > " .. tostr(b))
end

--- Assert that `a` is greater than `b`
-- @param a the actual value
-- @param b the lower limit
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_greater_than (a, b, message)
   assert(a > b, message or tostr(a) .. " <= " .. tostr(b))
end

--- Assert that `a` is greater than or equal to `b`
-- @param a the actual value
-- @param b the lower limit
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_greater_than_or_equal (a, b, message)
   assert(a >= b, message or tostr(a) .. " < " .. tostr(b))
end

--- Assert that 'actual' is a boolean value
-- @param actual the value to test for type
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_boolean(actual, message)
  if type(actual) ~= "boolean" then
    assert(false, message or tostring(actual).." is not a boolean")
  end
end

--- Assert that 'actual' is a string value
-- @param actual the value to test for type
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_string(actual, message)
  if type(actual) ~= "string" then
    assert(false, message or tostring(actual).." is not a string")
  end
end

--- Assert that 'actual' is a number value
-- @param actual the value to test for type
-- @param message override the default error message with `message` instead
-- @return nil
function TestCase:assert_number(actual, message)
  if type(actual) ~= "number" then
    assert(false, message or tostring(actual).." is not a number")
  end
end


--- The TestSuite class is a collection manager for test cases. Add test case instances to a TestSuite using `add_test_case`, then call the `run_suites` function to run the tests.
local TestSuite = class(
   nil,
   {
      name = nil,
      cases = {},
   }
)

function TestSuite:__init  (name)
   self.name = name
end


--- Add a test case instance to the test suite
-- @param test_case An instance of a subclass of TestCase
-- @return nil
function TestSuite:add_test_case (test_case)
   self.cases[#self.cases + 1] = test_case
end

--- Run all of the test cases added to the test suite
-- @return nil
function TestSuite:run ()
   for _, test_case in pairs(self.cases) do
      test_case:run()
   end
end

function TestSuite:_make_run_report ()
   local report = {tests_run=0, tests_failed=0}
   for _, test_case in pairs(self.cases) do
      report.tests_run = report.tests_run + test_case.tests_run
      report.tests_failed = report.tests_failed + test_case.tests_failed
   end
   return report
end


--- A helper function that runs an array of suites, builds a run report and logs the report to STDOUT
-- @return nil
local function run_suites (suites)
   for _, suite in pairs(suites) do
      log_info("Running tests in suite " .. suite.name)
      suite:run()
      local report = suite:_make_run_report()
      log_info("Finished suite: Ran " .. report.tests_run .. " with " .. report.tests_failed .. " failures")
   end
end
