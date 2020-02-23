pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib memory library
-- by sparr


------------------------------------------------------------------------
-- 75% the runtime of memcpy, len must be a multiple of 4
local function memcpy4(dst, src, len)
 for i = 0, len - 1, 4 do
  poke4(dst + i, peek4(src + i))
 end
end
-- this version can handle lengths that are not a multiple of 4
local _memcpy = memcpy
local function memcpy(dst, src, len)
 for i = 0, len - 4, 4 do
  poke4(dst + i, peek4(src + i))
 end
 _memcpy(dst + len - len % 4, src + len - len % 4, len % 4)
end
