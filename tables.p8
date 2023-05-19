pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib tables library
-- by sparr


------------------------------------------------------------------------
-- get value from table by key, with default
local function get(t, k, d)
 return t[k]~=nil and t[k] or d
end


------------------------------------------------------------------------
-- add value v to end of array t
-- supposedly faster but less safe than add(t,v)
local function add_(t, v)
 t[#t + 1] = v
end


------------------------------------------------------------------------
-- delete value v from array t, do not preserve order
local function del_r(t, v)
 for i = 1, #t do
  if (t[i] == v) t[i], t[#t] = t[#t], nil return
 end
end


------------------------------------------------------------------------
-- delete index i from array t, do not preserve order
local function deli_r(t, i)
 if (i > 0 and i <= #t) then -- remove[10,33]
  t[i], t[#t] = t[#t]
 end
end


------------------------------------------------------------------------
-- aliases to use table as stack
local pop = deli
local push = add_f


------------------------------------------------------------------------
-- delete and return the first item from array t
function shift(t)
 return deli(t, 1)
end


------------------------------------------------------------------------
-- add value v to the beginning of array t
function unshift(t, v)
 return add(t,v,1)
end


------------------------------------------------------------------------
-- copy keys and values from src to dst
-- also copy metatable if present in src
local function merge(dst, src)
 for k, v in pairs(src or {}) do
  dst[k] = copy(v)
 end
 setmetatable(dst, getmetatable(src) or getmetatable(dst))
 return dst
end


------------------------------------------------------------------------
-- creates a new table copied from o, using merge()
local function copy(o)
 return type(o) == 'table' and merge({}, o) or o
end
-- creates a new table copied from o, optionally overwriting with values from t
local function copy(o, t)
 if type(o) == 'table' then
  local c=merge({}, o)
  if (t) merge(c, t)
  return c
 else
  return o
 end
end
-- creates a new table copied from o, self contained
function copy(o)
 local c = {}
 for k,v in pairs(o) do
  c[k] = type(v) == "table" and copy(v) or v
 end
 return c
end

--- recursive/deep comparison of two tables
-- @tparam table a
-- @tparam table b
local function table_compare( a, b )
 for k, v in pairs( a ) do
  if type(v) == "table" and type(b[k]) == "table" then
   if ( not table.compare( v, b[k] ) ) return false
  else
   if ( v ~= b[k] ) return false
  end
 end
 for k, v in pairs( b ) do
  if ( a[k] == nil ) return false
 end
 return true
end


------------------------------------------------------------------------
-- adds values from src to end of dst, in order
local function concat(dst, src)
 local n=#dst -- inline[3,11] -- n+i becomes #dst+1
 for i=1,#src do
  dst[n+i]=src[i]
 end
end


------------------------------------------------------------------------
-- selects a random value from tbl
function tblrand(tbl)
 return t[flr(rnd(#t)) + 1]
end


------------------------------------------------------------------------
-- randomize the order of a table using fisher-yates shuffle
function shuffle(t)
  for i = #t, 1, -1 do
    local j = flr(rnd(i)) + 1
    t[i], t[j] = t[j], t[i]
  end
end


------------------------------------------------------------------------
-- bubble sort an array in place
function sort_bubble(t)
 for i,a in inext,t do
  for j,b in inext,t do
   if (a<b) a,t[i],t[j]=b,b,a
  end
 end
end

------------------------------------------------------------------------
-- bubble sort an array in place
-- second parameter extracts or calculates a sort key from each item
function sort_bubble_func(t, keyfn)
 local sortkeys = {}
 for i = 1, #t do
  sortkeys[i] = keyfn(t[i])
 end
 for i = 2, #t do
  for j = i, 2, -1 do
   if (sortkeys[j - 1] <= sortkeys[j]) break
   sortkeys[j], sortkeys[j - 1] = sortkeys[j - 1], sortkeys[j]
   t[j], t[j - 1] = t[j - 1], t[j]
  end
 end
end

------------------------------------------------------------------------
-- bubble sort an array in place
-- second parameter extracts or calculates a sort key from each item
-- second parameter is called multiple times per item
function sort_bubble_func_unsafe(t, keyfn)
 for i = 2, #t do
  for j = i, 2, -1 do
   if (keyfn(t[j-1]) <= keyfn(t[j])) break
   t[j], t[j - 1] = t[j - 1], t[j]
  end
 end
end

--- modified quick sort an array in place
-- @tparam table t the table to sort
-- @tparam[opt] number a starting index of slice to sort
-- @tparam[opt] number b ending index of slice to sort
-- quicksort chooses a pivot value, rearranges the table into {vals<=pivot, pivot, vals>=pivot}, recurses on both sides
function sort_quick(t, a, b)
 a, b = a or 1, b or #t
 if (a>=b) return
 -- p points to the pivot, initially the first item
 -- this has poor performance for already-sorted lists but reduces the token count of the algorithm
 -- r points to the value to be compared to the pivot, initially the last item
 local p,r = a,b
 while p < r do
  -- if the value being compared is already in the right place then
  -- leave it there and move the comparison pointer to the left.
  -- otherwise move the pivot value one space to the right,
  -- move the value from that spot to the comparison location,
  -- and move the value being compared to where the pivot was
  if (t[p]<t[r]) r-=1 else t[p],t[p+1],t[r]=t[r],t[p],t[p+1] p+=1
 end
 sort_quick(t,a,p-1)
 sort_quick(t,p+1,b)
end

local sort = sort_quick

------------------------------------------------------------------------
-- filter a table, keeping only key,value pairs that pass a check function
-- return a new table with the same keys/indices kept from the original
function filter(t, check)
 o = {}
 for k, v in pairs(t) do
  if (check(k,v)) o[k] = v
 end
 return o
end


------------------------------------------------------------------------
-- filter an array, keeping only values that pass check function
-- return a new array with sequential indices
function filter_array(t, check)
 o = {}
 for n in all(t) do
  if (check(v)) o[#o+1] = n
 end
 return o
end


------------------------------------------------------------------------
-- determine if any value in a table is truthy
function any(t)
 for k, v in pairs(t) do
  if (v) return true
 end
 return false -- optional if nil is acceptable
end


------------------------------------------------------------------------
-- determine if any value in a table passes check function
function any_func(t, check)
 for k, v in pairs(t) do
  if (check(v)) return true
 end
 return false -- optional if nil is acceptable
end


------------------------------------------------------------------------
-- determine if every value in a table is truthy
function all(t)
 for k, v in pairs(t) do
  if (not v) return false
 end
 return true
end


------------------------------------------------------------------------
-- determine if every value in a table is truthy or passes check function
function all_func(t, check)
 for k, v in pairs(t) do
  if (not check(v)) return false
 end
 return true
end


------------------------------------------------------------------------
-- iterate an array in reverse
-- used just like all()
function all_reverse(t)
 local i = #t
 return function()
  if (t==0) return nil
  i -= 1
  return t[i+1]
 end
end
