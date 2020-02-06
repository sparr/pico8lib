pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib physics library
-- by sparr

------------------------------------------------------------------------
-- check for collision/overlap of a point and a circle
-- 44 tokens
local function collision_point_circle(px, py, cx, cy, cr)
 local dx, dy = abs(px - cx), abs(py - cy)
 if (dx > cr or dy > cr) return false
 return dx * dx + dy * dy <= cr * cr
end
-- 29 tokens and faster
-- overflow and potential false positives for dx*dx+dy*dy > 32767
local function collision_point_circle(px, py, cx, cy, cr)
 local dx , dy = px - cx, py - cy
 return dx * dx + dy * dy <= cr * cr
end

