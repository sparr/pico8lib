pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico8lib tables library
-- by sparr


------------------------------------------------------------------------
-- Functions that operate on one table and one key and/or value

--- get value from table by key, with optional default for missing value
-- @tparam table t
-- @param k key
-- @param d default value
-- @return value if found, default otherwise
local function get(t, k, d)
 return t[k]~=nil and t[k] or d
end

--- add value to end of array
-- @tparam array a
-- @param v value to add
-- supposedly faster but less safe than add(a,v)
local function add_(a, v)
 a[#a + 1] = v
end

--- delete value from array, do not preserve order
-- @tparam array a
-- @param v value to delete
local function del_r(a, v)
 for i = 1, #a do
  if (a[i] == v) a[i], a[#a] = a[#a], nil return
 end
end

--- delete index from array, do not preserve order
-- @tparam array a
-- @tparam integer i index
local function deli_r(a, i)
 if (i > 0 and i <= #a) then -- remove[10,33]
  a[i], a[#a] = a[#a]
 end
end

-- aliases to use table as stack
local pop = deli
local push = add_f

--- delete and return the first item from array
-- @tparam array a
-- @return value of a[1] prior to deletion
function shift(a)
 return deli(a, 1)
end

--- add value to the beginning of array
-- @tparam array a
-- @param v value to add
function unshift(a, v)
 return add(a,v,1)
end

--- select a random value from an array
-- @tparam array a array to choose from
-- @return randomly chosen item from array
function rand_array(a)
 return a[flr(rnd(#a)) + 1]
end


------------------------------------------------------------------------
-- Functions that operate on two or more tables, or one table and return a new table

--- copy keys, values, and metatable from one table to another, using copy()
-- @tparam table d destination
-- @tparam table s source
-- @treturn table d
local function merge(d, s)
 -- for k, v in pairs(s or {}) do -- safety for missing s
 for k, v in pairs(s) do
  d[k] = copy(v)
 end
 setmetatable(d, getmetatable(s) or getmetatable(d))
 return d
end

--- create a copy of a variable, a deep copy if it's a table, using merge()
-- @param o variable to copy
-- @return copy of o
local function copy(o)
 return type(o) == 'table' and merge({}, o) or o
end

--- create a copy of a variable, a deep copy if it's a table, optionally merging another table over the copy
-- @param o variable to copy
-- @tparam[opt] table t table to merge over the copy
-- @return copy of o, optionally merged with t
local function copy_merge(o, t)
 if type(o) == 'table' then
  local c=merge({}, o)
  if (t) merge(c, t)
  return c
 else
  return o
 end
end

--- create a deep copy of a table
-- @tparam table o original table
-- @treturn table copy of o
function table_copy(o)
 local c = {}
 for k,v in pairs(o) do
  c[k] = type(v) == "table" and copy_table(v) or v
 end
 return c
end

--- recursive/deep comparison of two tables
-- @tparam table a
-- @tparam table b
-- @treturn boolean true iff tables have equal contents
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

--- recursive/deep comparison of two tables and their metatables
-- @tparam table a
-- @tparam table b
-- @treturn boolean true iff tables have equal contents and metatable contents
local function table_compare_meta( a, b )
 return table_compare( a, b ) and table_compare( getmetatable(a), getmetatable(b) )
end

--- add values from one array to the end of another
-- @tparam array d destination
-- @tparam array s source
local function concat(d, s)
 for i=1,#s do
  d[#d+1]=s[i]
 end
end


------------------------------------------------------------------------
-- Sorting functions

--- randomize the order of a table using fisher-yates shuffle
-- @tparam array a array to shuffle in place
function shuffle(a)
  for i = #a, 1, -1 do
    local j = flr(rnd(i)) + 1
    a[i], a[j] = a[j], a[i]
  end
end

--- sort an array in place, the slowest way
-- @tparam array a array to sort in place
function sort_slow(a)
 for i,v in inext,a do
  for j,w in inext,a do
   if (v<w) v,a[i],a[j]=w,w,v
  end
 end
end

--- sort an array in place, the slowest way
-- @tparam array a array to sort in place
function sort_slow_reverse(a)
 for i,v in inext,a do
  for j,w in inext,a do
   if (v>w) v,a[i],a[j]=w,w,v
  end
 end
end

--- sort an array in place, the slowest way, with a key function
-- @tparam array a array to sort in place
-- @tparam function f function to extract or calculate a comparison key for each value
function sort_slow_func(a, f)
 local k = {}
 for i = 1, #a do
  k[i] = f(a[i])
 end
 for i,v in inext,k do
  for j,w in inext,k do
   if (v<w) v,k[i],k[j],a[i],a[j]=w,w,v,a[j],a[i]
  end
 end
end

--- sort an array in place, the slowest way, with a key function
-- @tparam array a array to sort in place
-- @tparam function f function to extract or calculate a comparison key for each value
function sort_slow_func_unsafe(a, f)
 for i,v in inext,a do
  for j,w in inext,a do
   if (f(v)<f(w)) v,a[i],a[j]=w,w,v
  end
 end
end

--- sort an array in place, the slowest way, with a comparison function
-- @tparam array a array to sort in place
-- @tparam function f function to compare two values
function sort_slow_cmp(a, f)
 for i,v in inext,k do
  for j,w in inext,k do
   if (f(v,w)) v,a[i],a[j]=w,w,v
  end
 end
end

--- sort an array in place, modified quicksort
-- @tparam array a the table to sort
-- @tparam[opt] number i starting index of slice to sort
-- @tparam[opt] number j ending index of slice to sort
-- quicksort chooses a pivot value, rearranges the table into {vals<=pivot, pivot, vals>=pivot}, recurses on both sides
function sort_quick(a, i, j)
 i, j = i or 1, j or #a
 if (i>=j) return
 -- p points to the pivot, initially the first item
 -- this has poor performance for already-sorted lists but reduces the token count of the algorithm
 -- r points to the value to be compared to the pivot, initially the last item
 local p,r = i,j
 while p < r do
  -- if the value being compared is already in the right place then
  -- leave it there and move the comparison pointer to the left.
  -- otherwise move the pivot value one space to the right,
  -- move the value from that spot to the comparison location,
  -- and move the value being compared to where the pivot was
  if (a[p]<a[r]) r-=1 else a[p],a[p+1],a[r]=a[r],a[p],a[p+1] p+=1
 end
 sort_quick(a,i,p-1)
 sort_quick(a,p+1,j)
end

--- sort an array in place, modified quicksort, with a key function
-- @tparam array a the table to sort
-- @tparam function f function to extract or calculate a comparison key for each value
-- @tparam[opt] number i starting index of slice to sort
-- @tparam[opt] number j ending index of slice to sort
function sort_quick_func(a, f, i, j)
 i, j = i or 1, j or #a
 if (i>=j) return
 local p,r = i,j
 while p < r do
  if (f(a[p])<f(a[r])) r-=1 else a[p],a[p+1],a[r]=a[r],a[p],a[p+1] p+=1
 end
 sort_quick(a,f,i,p-1)
 sort_quick(a,f,p+1,j)
end

--- sort an array in place, modified quicksort, with a comparison function
-- @tparam array a the table to sort
-- @tparam function f function to compare two values
-- @tparam[opt] number i starting index of slice to sort
-- @tparam[opt] number j ending index of slice to sort
function sort_quick_func(a, f, i, j)
 i, j = i or 1, j or #a
 if (i>=j) return
 local p,r = i,j
 while p < r do
  if (f(a[p],a[r])) r-=1 else a[p],a[p+1],a[r]=a[r],a[p],a[p+1] p+=1
 end
 sort_quick(a,f,i,p-1)
 sort_quick(a,f,p+1,j)
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

--- reverses the items in an array
-- @tparam array a
function reverse(a)
 for i=1,#a\2 do
  a[i],a[#a-i+1]=a[#a-i+1],a[i]
 end
end
