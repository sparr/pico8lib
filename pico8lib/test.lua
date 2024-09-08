--- @module test
--- Unit testing


-- #include class.lua
-- #include log.lua
-- #include functions.lua
-- #include strings.lua
-- #include tables.lua

--- The TestCase class represents a collection of tests to be run for a given context. Subclass TestCase and add functions starting with "test_" then add an instance to a TestSuite instance to run your tests. For an example of how do this, see the `Assertions` test case in `test/test_test.p8`.
-- @type TestCase
local TestCase = class(
   nil,
   {
      name = nil,
      tests_run = 0,
      tests_failed = 0,
   }
)

--- Constructor
-- @tparam string name TestCase naming convention: snake_case
-- @tparam function setup Run before each test function is executed, to setup state relevant to the test on the TestCase instance. Override this method as needed in your TestCase subclass.
-- @tparam function teardown Run after each test function is executed, to reset state relevant to the test on the TestCase instance. Override this method as needed in your TestCase subclass.
function TestCase:__init (name, setup, teardown)
   self.name = name
   if setup then self.setup = setup end
   if teardown then self.teardown = teardown end
end


function TestCase:_parse_error_message (e)
   local parts = split(e, ":")
   return #parts == 1 and e or sub(parts[#parts], 2)
end

--- Call all of the test functions that start with "test_" and track failures.
-- @tparam[opt] boolean quiet Suppress PASS/FAIL output per test
function TestCase:run (quiet)
   test_names = {}
   for key, val in pairs(self) do
      if type(val) == "function" and starts_with(key, "test_") then
         test_names[#test_names+1] = key
      end
   end
   sort(test_names)
   for _, test_name in ipairs(test_names) do
      try(
         function ()
            if self.setup then self.setup() end
            self[test_name](self)
            if self.teardown then self.teardown() end
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
-- @tparam function fn A function to be called
-- @tparam string expected_message The exact text of the expected exception
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

--- Assert that value is nil
-- @param any a value that is expected to be nil
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_nil (any, message)
   assert(any == nil, message or tostr(tostr(any) .. " is not nil"))
end

--- Assert that value is not nil
-- @param any a value that is expected to not be nil
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_not_nil (any, message)
   assert(any != nil, message or tostr(any) .. " is unexpectedly nil")
end

--- Assert that value is true
-- @param any a value that is expected to be true
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_true (any, message)
   assert(any, message or "unexpectedly false")
end

--- Assert that value is false
-- @param any a value that is expected to be false
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_false (any, message)
   assert(not any, message or "unexpectedly true")
end

--- Assert that `a` is equal to `b`
-- @param a the actual object
-- @param b the expected object
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_equal (a, b, message)
   -- printh("y")
   -- printh(a:__eq(b))
   -- printh(type(b))
   assert(a == b, message or tostr(a) .. " ~= " .. tostr(b))
end

--- Assert that `a` is almost equal to `b`, useful for comparing floating points.
-- @tparam number a the actual floating point value
-- @tparam number b the expected floating point value
-- @tparam number tolerance the absolute variance allowed between `a` and `b`
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_almost_equal(a, b, tolerance, message)
   assert(abs(a - b) <= tolerance, message or tostr(a) .. " ~= " .. tostr(b) .. " (tolerance=" .. tolerance .. ")")
end

--- Assert that `a` is not equal to `b`
-- @param a the actual object
-- @param b the undesired object
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_not_equal (a, b, message)
   assert(a ~= b, message or tostr(a) .. " == " .. tostr(b))
end

-- Assert that the table contains the expected key
-- @tparam table tbl the table to check
-- @param key the key to search for in the table
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_in (tbl, key, message)
   assert(not tbl[key] == nil, message or tostr(key) .. " not found in table")
end

-- Assert that the table does not contain the expected key
-- @tparam table tbl the table to check
-- @param key the key to search for in the table
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_not_in (tbl, key, message)
   assert(tbl[key] == nil, message or tostr(key) .. " unexpectedly found in table")
end

--- Assert that `a` is less than `b`
-- @param a the actual value
-- @param b the upper limit
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_less_than (a, b, message)
   assert(a < b, message or tostr(a) .. " >= " .. tostr(b))
end

--- Assert that `a` is less than or equal to `b`
-- @param a the actual value
-- @param b the upper limit
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_less_than_or_equal (a, b, message)
   assert(a <= b, message or tostr(a) .. " > " .. tostr(b))
end

--- Assert that `a` is greater than `b`
-- @param a the actual value
-- @param b the lower limit
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_greater_than (a, b, message)
   assert(a > b, message or tostr(a) .. " <= " .. tostr(b))
end

--- Assert that `a` is greater than or equal to `b`
-- @param a the actual value
-- @param b the lower limit
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_greater_than_or_equal (a, b, message)
   assert(a >= b, message or tostr(a) .. " < " .. tostr(b))
end

--- Assert that 'actual' is a boolean value
-- @param actual the value to test for type
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_boolean(actual, message)
  if type(actual) ~= "boolean" then
    assert(false, message or tostring(actual).." is not a boolean")
  end
end

--- Assert that 'actual' is a string value
-- @param actual the value to test for type
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_string(actual, message)
  if type(actual) ~= "string" then
    assert(false, message or tostring(actual).." is not a string")
  end
end

--- Assert that 'actual' is a number value
-- @param actual the value to test for type
-- @tparam[opt] string message override the default error message with `message` instead
function TestCase:assert_number(actual, message)
  if type(actual) ~= "number" then
    assert(false, message or tostring(actual).." is not a number")
  end
end


--- The TestSuite class is a collection manager for test cases.
-- Add test case instances to a TestSuite using `add_test_case`,
-- then call the `run_suites` function to run the tests.
-- @type TestSuite
local TestSuite = class(
   nil,
   {
      name = nil,
      cases = nil,
   }
)

function TestSuite:__init (name)
   self.name = name
   self.cases = {}
end

--- Add a test case instance to the test suite
-- @tparam TestCase test_case An instance of a subclass of TestCase
function TestSuite:add_test_case (test_case)
   self.cases[#self.cases + 1] = test_case
end

--- Create a new test case instance and add it to the test suite
-- @tparam string name name for the new test case
-- @treturn TestCase the new test case
function TestSuite:new_test_case (name)
   local case = TestCase(name)
   self.cases[#self.cases + 1] = case
   return case
end

--- Run all of the test cases added to the test suite
-- @tparam[opt] boolean quiet Suppress PASS/FAIL output per test
function TestSuite:run (quiet)
   for _, test_case in pairs(self.cases) do
      test_case:run(quiet)
   end
end

--- Count run and failed tests for all run cases
-- @return table of run and failed counts
function TestSuite:make_run_report ()
   local report = {tests_run=0, tests_failed=0}
   for _, test_case in pairs(self.cases) do
      report.tests_run = report.tests_run + test_case.tests_run
      report.tests_failed = report.tests_failed + test_case.tests_failed
   end
   return report
end


--- A helper function that runs an array of suites, builds a run report and logs the report to STDOUT
local function run_suites (suites)
   for _, suite in pairs(suites) do
      log_info("Running tests in suite " .. suite.name)
      suite:run()
      local report = suite:make_run_report()
      log_info("Finished suite: Ran " .. report.tests_run .. " with " .. report.tests_failed .. " failures")
   end
end
