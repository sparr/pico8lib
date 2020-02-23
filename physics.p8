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


------------------------------------------------------------------------
-- distance from circle to line with optional width
-- wide line includes a circular cap at each end
-- negative distance indicates depth of overlap
function dist_circ_line_w(x, y, r, x0, y0, x1, y1, w)
 local dx, dy, ax, ay = x1 - x0, y1 - y0, x - x0, y - y0
 local t, d = ax * dx + ay * dy, dx * dx + dy * dy
 t = d == 0 and 0 or mid(t, 0, d) / d
 x, y = abs(x0 + t * dx - x), abs(y0 + t * dy - y)
 if (x < 128 and y < 128) return sqrt(x * x + y * y) - r - (w or 0)
 -- condition above and code path below avoid overflow for large x and/or y
 local d = max(x, y)
 local n = x / d * y / d
 return sqrt(n * n + 1) * d - r - (w or 0)
end
