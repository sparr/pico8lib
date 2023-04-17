pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib unit test library
-- by mindfilleter

-- Depends on pico8lib/[class.p8, log.p8, functions.p8, string.p8]

local TestCase = class(
   nil,
   {
      name = nil,
      tests_run = 0,
      tests_failed = 0,
   }
)

function TestCase:__init (name)
   self.name = name
end

function TestCase:setup ()
   -- NOOP
end

function TestCase:teardown ()
   -- NOOP
end

function TestCase:_parse_error_message (e)
   local parts = split(e, ":")
   return sub(parts[#parts], 2)
end

function TestCase:run ()
   for key, value in pairs(self.__index) do
      if type(value) == "function" and starts_with(key, "test_") then
         try(
            function ()
               value(self)
               log_info("TestCase:" .. self.name .. ":" .. key .. " ... PASS")
            end,
            function (e)
               self.tests_failured = self.tests_failed + 1
               log_err(self.name .. ":" .. key .. " " .. self:_parse_error_message(e))
            end,
            function ()
               self.tests_run = self.tests_run + 1
            end
         )
      end
   end
end

function TestCase:assert_throws(fn, expected_message)
   local threw = false
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

function TestCase:assert_nil (any, message)
   assert(any == nil, message or tostr(tostr(any) .. " is not nil"))
end

function TestCase:assert_not_nil (any, message)
   assert(any != nil, message or tostr(any) .. " is unexpectedly nil")
end

function TestCase:assert_true (any, message)
   assert(any, message or "unexpectedly false")
end

function TestCase:assert_false (any, message)
   assert(not any, message or "unexpectedly true")
end

function TestCase:assert_equal (a, b, message)
   assert(a == b, message or tostr(a) .. " ~= " .. tostr(b))
end

function TestCase:assert_not_equal (a, b, message)
   assert(a ~= b, message or tostr(a) .. " == " .. tostr(b))
end

function TestCase:assert_in (tbl, key, message)
   assert(not tbl[key] == nil, message or tostr(key) .. " not found in table")
end

function TestCase:assert_not_in (tbl, key, message)
   assert(tbl[key] == nil, message or tostr(key) .. " unexpectedly found in table")
end

function TestCase:assert_less_than (a, b, message)
   assert(a < b, message or tostr(a) .. " >= " .. tostr(b))
end

function TestCase:assert_less_than_or_equal (a, b, message)
   assert(a <= b, message or tostr(a) .. " > " .. tostr(b))
end

function TestCase:assert_greater_than (a, b, message)
   assert(a > b, message or tostr(a) .. " <= " .. tostr(b))
end

function TestCase:assert_greater_than_or_equal (a, b, message)
   assert(a >= b, message or tostr(a) .. " < " .. tostr(b))
end


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

function TestSuite:add_test_case (test_case)
   self.cases[#self.cases + 1] = test_case
end

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


local function run_suites (suites)
   for _, suite in pairs(suites) do
      log_info("Running tests in suite " .. suite.name)
      suite:run()
      local report = suite:_make_run_report()
      log_info("Finished suite: Ran " .. report.tests_run .. " with " .. report.tests_failed .. " failures")
   end
end
