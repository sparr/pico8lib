pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

#include ../pico8lib/strings.lua
#include ../pico8lib/log.lua

life = 0
save_file_exists = false
fps = 30

P8LIBLOGUTC = true
P8LIBLOGLVL = 4
log_debug("Doing setup")
log_info("Disabling debug level logging")
P8LIBLOGLVL = 3
log_debug("Finished setup") -- disabled
if (life == 0) log_err("Oh no! life is zero!")
if (not save_file_exists) log_warn("No save file found.")
log_info("FPS:" .. fps)

log_info("Switching from UTC to Local time")
P8LIBLOGUTC = false
log_info("Disabling info level logging")
P8LIBLOGLVL = 2
if (life == 0) log_err("Oh no! life is zero!")
if (not save_file_exists) log_warn("No save file found.")
log_info("FPS:" .. fps) -- disabled

log_info("Disabling warning level logging") -- disabled
P8LIBLOGLVL = 1
if (life == 0) log_err("Oh no! life is zero!")
if (not save_file_exists) log_warn("No save file found.") -- disabled
log_info("FPS:" .. fps) -- disabled


-- Example output
-- $ pico8 -x log.p8
-- RUNNING: log.p8
-- 2024-09-08 07:52:17 DBG - Doing setup
-- 2024-09-08 07:52:17 INF - Disabling debug level logging
-- 2024-09-08 07:52:17 ERR - Oh no! life is zero!
-- 2024-09-08 07:52:17 WRN - No save file found.
-- 2024-09-08 07:52:17 INF - FPS:30
-- 2024-09-08 07:52:17 INF - Switching from UTC to Local time
-- 2024-09-08 03:52:17 INF - Disabling info level logging
-- 2024-09-08 03:52:17 ERR - Oh no! life is zero!
-- 2024-09-08 03:52:17 WRN - No save file found.
-- 2024-09-08 03:52:17 ERR - Oh no! life is zero!