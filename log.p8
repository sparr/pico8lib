pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib logging library
-- by mindfilleter

-- Depends on pico8lib/strings.p8

--- Log the passed in object to STDOUT
-- The passed in object will be converted to a string and then logged with a
-- timestamp.
-- @param level A level prefix to prepend to the message
-- @param any The object to log
-- @return nil
local function log (level, any)
   local message = stat(90)
   message = message .. "-" .. stat(91)
   message = message .. "-" .. stat(92)
   message = message .. " " .. stat(93)
   message = message .. ":" .. stat(94)
   message = message .. ":" .. stat(95)
   printh(message .. level .. " - " .. tostr(any))
end


--- Log the passed in object to STDOUT with the INFO tag
-- See the `log` function for details
-- @param any The object to log
-- @return nil
local function log_info (any)
   log("INFO", any)
end

--- Log the passed in object to STDOUT with the WARN tag
-- See the `log` function for details
-- @param any The object to log
-- @return nil
local function log_warn (any)
   log("WARN", any)
end

--- Log the passed in object to STDOUT with the ERR tag
-- See the `log` function for details
-- @param any The object to log
-- @return nil
local function log_err (any)
   log("ERR", any)
end
