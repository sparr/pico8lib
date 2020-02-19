pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- name of cart
-- by author
-- ^^ these two lines will be rendered to the cart label

-- code at the top level will be run once when the cart loads
-- local variables here are accessible to every function
-- global variables here are also accessible from the console when the cart is stopped

-- profiling metric storage and configuration
local _profile_update, _profile_draw, _profile_color, _profile_x, _profile_y = 0, 0, 14, 0, 0

function _init()
 -- this function will be run once when the cart loads
 -- you might also call it to reset your cart state
 -------------------------
 -- init code goes here --
 -------------------------
end

-- 30fps update function is generally not used
-- function _update()
-- end

function _update60()
 _profile_update = stat(1) -- record cpu usage at the start of the update
 ---------------------------
 -- update code goes here --
 ---------------------------
 -- simple handling of first player button inputs
 if btnp(0) then end -- left
 if btnp(1) then end -- right
 if btnp(2) then end -- up
 if btnp(3) then end -- down
 if btnp(4) then end -- x
 if btnp(5) then end -- o
 _profile_update = stat(1) - _profile_update -- record total cpu usage of update
end

function _draw()
 _profile_draw = stat(1) -- record cpu usage at the start of the draw
 cls()
 -------------------------
 -- draw code goes here --
 -------------------------
 _profile_draw = stat(1) - _profile_draw -- record total cpu usage of draw
 -- print profiling and performance information
 -- clobbers previous cursor and color
 cursor(_profile_x, _profile_y)
 color(_profile_color)
 print("time:" .. tostr(t()))
 print("updt:" .. tostr(_profile_update))
 print("draw:" .. tostr(_profile_draw))
 print(" fps:" .. tostr(stat(7)))
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
