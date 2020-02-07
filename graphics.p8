pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib graphics library
-- by sparr

------------------------------------------------------------------------
-- bresenham's line drawing algorithm
local function line_(x1, y1, x2, y2, c)
 local dx, dy, sx, sy = abs(x2 - x1), -abs(y2 - y1), x1 < x2 and 1 or -1, y1 < y2 and 1 or -1
 local e = dx + dy
 pset(x1, y1, c)
 while x1 ~= x2 or y1 ~= y2 do
  local t = 2 * e
  if t > dy then
   e = e + dy
   x1 = x1 + sx
  end
  if t < dx then
   e = e + dx
   y1 = y1 + sy
  end
  pset(x1, y1, c)
 end
end
-- fx fy are how many extra pixels right/down to make each pixel of the line
local function line_fat(x1, y1, x2, y2, c, fx, fy)
 local dx, dy, sx, sy = abs(x2 - x1), -abs(y2 - y1), x1 < x2 and 1 or -1, y1 < y2 and 1 or -1
 local e = dx + dy
 rectfill(x1, y1, x1 + fx, y1 + fy, c)
 while x1 ~= x2 or y1 ~= y2 do
  local t = 2 * e
  if t > dy then
   e = e + dy
   x1 = x1 + sx
  end
  if t < dx then
   e = e + dx
   y1 = y1 + sy
  end
  rectfill(x1, y1, x1 + fx, y1 + fy, c)
 end
end
-- calls f() for each pixel of the line
-- line_func(...,pset) is equivalent to line_(...)
local function line_func(x1, y1, x2, y2, c, f)
 local dx, dy, sx, sy = abs(x2 - x1), -abs(y2 - y1), x1 < x2 and 1 or -1, y1 < y2 and 1 or -1
 local p,e = 0, dx + dy
 f(x1, y1, c, p)
 while x1 ~= x2 or y1 ~= y2 do
  p += 1
  local t = 2 * e
  if t > dy then
   e = e + dy
   x1 = x1 + sx
  end
  if t < dx then
   e = e + dx
   y1 = y1 + sy
  end
  f(x1, y1, c, p)
 end
end

------------------------------------------------------------------------
-- draw a 4x4 sprite
local function spr4(sn, x, y)
 sspr(sn % 32 * 4, flr(sn / 32) * 4, 4, 4, x, y)
end
local function spr4(sn, x, y, w, h, ...) -- supports w,h,flip_h,flip_v, but much slower (2.5x runtime)
 sspr(sn % 32 * 4, flr(sn / 32) * 4, (w or 1) * 4, (h or 1) * 4, x, y, (w or 1) * 4, (h or 1) * 4, ...)
end

------------------------------------------------------------------------
-- draw a circle of even diameter
-- x,y is top left corner of bounding box
-- r is radius, 1-8
-- c is color
-- necessary sprite:
-- 88888777
-- 88877866
-- 88786655
-- 87865544
-- 87658433
-- 78654322
-- 76543281
-- 76543210
local function circeven(x, y, r, c)
 -- c = c or band(peek(24357), 15) -- make color optional
 for t = 0, 8 do
  palt(t, r ~= t + 1)
 end
 pal(r - 1, c)
 for i = 0, 1 do
  for j = 0, 1 do
   spr(1, x + i * 8 - 8 + r, y + j * 8 - 8 + r, 1, 1, i > 0, j > 0)
  end
 end
 palt() -- optional if other code makes no expectations about transparency
end


------------------------------------------------------------------------
local function flrceil(x, d) return d * flr(x*d) end
-- draws every pixel outside a given circle
-- fixme does not match circ/circfill boundary exactly
local function circinverse(x, y, r, c)
 -- -1 and 128 are rectangle bounds
 -- outside the screen so that we don't accidentally draw borders when the other coordinate is also outside
 for lrr = -1, 128, 129 do
  -- -1 and +1 are used to draw mirror images of the bounding rectangles
  local lr = sgn(lrr)
  rectfill(-1, lrr, 128, flrceil(y + (r + 1) * lr, -lr), c) -- big top/bottom rectangles
  -- flrceil from math.p8
  rectfill(flrceil(x + (r + 1) * lr, -lr),flrceil(y - r * lr, lr), lrr, flrceil(y + r * lr, -lr), c) -- smaller side rectangles
 end
 -- cx and cy are coordinates relative to the center that walk from east to southheast
 -- following the bresenham circle algorithm
 local cx, cy, rs = flrceil(r, -1), 0, (r + 0.5) * (r + 0.5)
 while cy <= cx do
  if cy * cy + cx * cx > rs then
   -- only draw lines and decrement cx when cy has moved enough to get outside the circle (bresenham algorithm)
   -- again -1 and +1 are used to draw mirror images   
   for dx = -1, 1, 2 do
    for dy = -1, 1, 2 do
     -- todo switch to line() if it ever benchmarks faster than rectfill here
     rectfill(flrceil(x + cx * dx, dx), flrceil(y + cy * dy, dy), flrceil(x + cx * dx, dx), flrceil(y + r * dy - (r - cx) * dy, dy), c) -- vertical lines
     if (cy < cx) rectfill(flrceil(x + cy * dx, dx), flrceil(y + cx * dy, dy), flrceil(x + (cx - 1) * dx, dx), flrceil(y + cx * dy, dy), c) -- horizontal lines
    end
   end
   cx -= 1
  end
  cy += 1
 end
end

------------------------------------------------------------------------
-- draws every pixel outside a given rectangle
local function rectinverse(x, y, i, j, c)
 if (x > i) x, i = i, x
 if (y > j) y, j = j, y
 rectfill(-1, -1, 128, y - 1, c)
 rectfill(-1, 128, 128, j + 1, c)
 rectfill(-1, y, x - 1, j, c)
 rectfill(128, y, i + 1, j, c)
end


------------------------------------------------------------------------
-- fillp with support for x/y offsets to shift the mask
-- original algorithm from https://www.lexaloffle.com/bbs/?tid=30518
-- heavily token optimized by sparr
local _fillp = fillp
local function fillp(p, x, y)
    p, x, y = p or 0, x or 0, y or 0 -- remove[13,36] backward compatibility with fillp(p)
    local p16, x = flr(p), band(x, 3)
    local f, p32 = flr(15 / shl(1,x)) * 0x1111, rotr(p16 + lshr(p16, 16), band(y, 3) * 4 + x) -- shl is more tokens than ^ but much faster
    return _fillp(p - p16 + flr(band(p32, f) + band(rotl(p32, 4), 0xffff - f)))
end

__gfx__
0000000088888777
0000000088877866
0000000088786655
0000000087865544
0000000087658433
0000000078654322
0000000076543281
0000000076543210