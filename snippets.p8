-- pico8lib snippets library
-- by sparr

-- this code is meant to be copied inline, not necessarily used as functions,
-- with your own own code inserted in the appropriate place

local function snippet_eight_neighbors()
 for y = -1, 1 do
  for x = -1, 1, y==0 and 2 or 1 do
   -- insert code here using x and y as offsets
  end
 end
end
