---@diagnostic disable
---
--- Tests for commenting in visual and normal mode
--- and creating a comments ahead of the line
---
a = "comment/uncomment a single line"

function z()

  --- ^ start a comment when the line is empty, with indentation
end

--- dotrepeat and counts should work to comment/uncomment
---
--- in visual mode test reverse selections
--- by using `o` to reverse the selection
function b()
  print("foo")

  --- ^ empty lines are completely ignored
  --- uncomment only when all selected lines are commented
  -- local c = nil
  -- local d = nil
end

--- Tests for toggling comments ahead/top

-- should do nothing to this line

-- shold not join those comments together
-- no matter where you try to toggle them
-- even from the empty lines around

--- test toggling from every single line, it should work from any point
--- and keep the indentation correct

-- on top of this function
function abc()
  -- try toggling with the cursor on the comment line
  print()

  -- another comment
  print("try toggling with the cursor on the line below the comment")

  -- should toggle normaly when mixed with multiple kind comments
  print("one") -- even
  print("two") -- more
  print("three") -- comments

  -- this should indent properly
end

--- Tests for Block comments
-- Test everything in both normal and reverse selection, and test uncommenting
-- Try visual line commenting
-- Try commenting on the same line
-- In multiline selections, Try commenting in a point before the starting position of the selection

--     (.)  (.)    (.)
-- (.)      (.)       (.)
--     (.)      (.)

--- also test for block comments on `./tests/test.html`
-- vim: set nofoldenable:
