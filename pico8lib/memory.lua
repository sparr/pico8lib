--- @module memory
--- Reading, writing, manipulating memory


--- Copy a block of memory from `src` to `dst`
-- @param dst The offset to copy to
-- @param src The offset to copy from
-- @param len The number of bytes to copy (must be a multiple of 4)
-- @return null
local function memcpy4(dst, src, len)
 for i = 0, len - 1, 4 do
  poke4(dst + i, $(src+i))
 end
end


local _memcpy = memcpy
--- Copy a block of memory from `src` to `dst`
local function memcpy(dst, src, len)
 for i = 0, len - 4, 4 do
  poke4(dst + i, $(src + i))
 end
 -- todo benchmark poke/peek loop
 _memcpy(dst + len - len % 4, src + len - len % 4, len % 4)
end


--- Compare two regions of memory
-- @tparam number a First starting memory address
-- @tparam number b Second starting memory address
-- @tparam number l Length of regions to compare (must be a multiple of 4)
-- @treturn boolean True iff the regions are identical
local function memcmp4(a, b, l)
 for i = 0, l - 1, 4 do
  if $(a + i) != $(b + i) then
   return false
  end
 end
 return true
end

--- Compare two regions of memory
-- @tparam number a First starting memory address
-- @tparam number b Second starting memory address
-- @tparam number l Length of regions to compare
-- @treturn boolean True iff the regions are identical
local function memcmp(a, b, l)
 if not memcmp4(a,b,l-l%4) then return false end
 -- FIXME correctly handle l<3
 for i = l - 3, l - 1 do
  if @(a + i) != @(b + i) then
   return false
  end
 end
 return true
end
