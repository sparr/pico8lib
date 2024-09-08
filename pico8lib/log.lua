--- @module log
--- A module for logging output to STDOUT


-- #include strings.lua

--- P8LIBLOGLVL configures the logging functions to only output certain log levels.
-- - 0 - disable logging
-- - 1 - errors only
-- - 2 - warnings and errors
-- - 3 - all logs (info, warnings, and errors)
local P8LIBLOGLVL = 3


--- P8LIBLOGUTC configures the output to either use UTC or local time.
-- false (default) for local time, true for UTC
local P8LIBLOGUTC = false


--- Log the passed in object to STDOUT
-- The passed in object will be converted to a string and then logged with a
-- timestamp.
-- @param prefix A prefix to prepend to the message
-- @param any The object to log
-- @return nil
local function log (prefix, any)
   tz = P8LIBLOGUTC and 80 or 90
   seconds = stat(tz+5)
   printh(stat(tz) .. "-" ..
          stat(tz+1) .. "-" ..
          stat(tz+2) .. " " ..
          stat(tz+3) .. ":" ..
          stat(tz+4) .. ":" ..
          (seconds < 10 and "0" .. seconds or seconds)
          .. " " .. prefix .. " - " .. tostr(any))
end


--- Log the passed in object to STDOUT with the INFO tag
-- See the `log` function for details
-- @param any The object to log
-- @return nil
local function log_info (any)
   if (P8LIBLOGLVL >= 3) log("INF", any)
end


--- Log the passed in object to STDOUT with the WARN tag
-- See the `log` function for details
-- @param any The object to log
-- @return nil
local function log_warn (any)
   if (P8LIBLOGLVL >= 2) log("WAR", any)
end


--- Log the passed in object to STDOUT with the ERR tag
-- See the `log` function for details
-- @param any The object to log
-- @return nil
local function log_err (any)
   if (P8LIBLOGLVL >= 1) log("ERR", any)
end


