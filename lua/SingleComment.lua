---@type table
local M = {}
---@type table
local comments = require("SingleComment.kinds")

--- inserts a comment at the end of the current line
function M.SingleCommentAhead()
  local comment
  if comments[vim.o.ft] then
    comment = comments[vim.o.ft]
  else
    comment = { "", "" }
  end

  local line = vim.api.nvim_get_current_line()
    .. " "
    .. comment[1]
    .. comment[2]

  vim.api.nvim_set_current_line(line)

  if comment[2] ~= "" then
    vim.api.nvim_input("A" .. string.rep("<left>", #comment[2]))
  else
    vim.api.nvim_input("A ")
  end
end

--- comments single lines
function M.SingleComment()
  local comment
  if comments[vim.o.ft] then
    comment = comments[vim.o.ft]
  else
    comment = { "", "" }
  end

  local count = vim.v.count
  local col = vim.fn.col(".") - 1
  local startRow, endRow = vim.fn.line("v"), vim.fn.line(".")
  local pos = { startRow, col }

  -- in case the selection starts from the bottom
  if startRow > endRow then
    local tmp = startRow
    startRow = endRow
    endRow = tmp
    pos = { endRow, col }
  end

  if count ~= 0 then
    endRow = endRow + count - 1
  end

  local lines = vim.api.nvim_buf_get_lines(0, startRow - 1, endRow, true)
  local indent = string.match(lines[1], "^%s*")

  local uncomment
  for i, _ in ipairs(lines) do
    if not lines[i]:match("^%s*$") then
      if not lines[i]:match("^" .. indent .. vim.pesc(comment[1])) then
        uncomment = true
        break
      end
    end
  end

  for i, _ in ipairs(lines) do
    if not lines[i]:match("^%s*$") then
      lines[i] = string.gsub(lines[i], "^" .. indent, "")

      if not uncomment then
        lines[i] = lines[i]
          :gsub("^" .. vim.pesc(comment[1]), indent)
          :gsub(vim.pesc(comment[2]) .. "$", "")
      else
        lines[i] = indent .. comment[1] .. lines[i] .. comment[2]
      end
    end
  end

  vim.api.nvim_buf_set_lines(0, startRow - 1, endRow, true, lines)
  vim.api.nvim_input("<esc>")
  vim.api.nvim_win_set_cursor(0, pos)
end

return M
