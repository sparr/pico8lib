--- @module log
--- A module for logging output to STDOUT


-- #include strings.lua

--- P8LIBLOGLVL configures the logging functions to only output certain log levels.
-- - 0 - disable logging
-- - 1 - errors only
-- - 2 - errors and warnings
-- - 3 - errors, warnings, info
-- - 4 - errors, warnings, info, debug (aka everything)
local P8LIBLOGLVL = 3


--- P8LIBLOGUTC configures the output to either use UTC or local time.
-- false (default) for local time, true for UTC
local P8LIBLOGUTC = false

--- Log the passed in object to STDOUT
-- The passed in object will be converted to a string and then logged with a
-- timestamp.
-- @param any The object to log
-- @tparam string prefix A prefix to prepend to the message
local function log (any, prefix)
   tz = P8LIBLOGUTC and 80 or 90
   seconds = stat(tz+5)
   printh(stat(tz) .. "-" ..
          stat(tz+1) .. "-" ..
          stat(tz+2) .. " " ..
          stat(tz+3) .. ":" ..
          stat(tz+4) .. ":" ..
          (seconds < 10 and "0" .. seconds or seconds)
          .. " " .. (prefix or "LOG") .. " - " .. tostr(any))
end


--- Log the passed in object to STDOUT with the DBG tag
-- See the `log` function for details
-- @param any The object to log
local function log_debug (any)
   if (P8LIBLOGLVL >= 4) log(any, "DBG")
end


--- Log the passed in object to STDOUT with the INF tag
-- See the `log` function for details
-- @param any The object to log
local function log_info (any)
   if (P8LIBLOGLVL >= 3) log(any, "INF")
end


--- Log the passed in object to STDOUT with the WRN tag
-- See the `log` function for details
-- @param any The object to log
local function log_warn (any)
   if (P8LIBLOGLVL >= 2) log(any, "WRN")
end


--- Log the passed in object to STDOUT with the ERR tag
-- See the `log` function for details
-- @param any The object to log
local function log_err (any)
   if (P8LIBLOGLVL >= 1) log(any, "ERR")
end


