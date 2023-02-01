---@type table
local M = {}
---@type table block comments that can be changed to line comments
local blocks = {
  ["/*"] = { "// ", "" },
  ["/* "] = { "// ", "" },
  ["<!--"] = { "<!-- ", " -->" },
}
---@type table filetypes that behave
local exceptions = {
  json = { "// ", "" },
  css = { "/* ", " */" },
}

---@return table
--- returns a table with the comment beginning/end
local function GetComment()
  local comment = {}
  local filetype = vim.bo.ft

  -- get commentstring using ts_context_commentstring
  if vim.g.SC_ts_context then
    require("ts_context_commentstring.internal").update_commentstring({})
  end

  local commentstring = vim.bo.commentstring

  if exceptions[filetype] ~= nil then
    comment = exceptions[filetype]
  elseif commentstring == "" or commentstring == nil then
    comment = { "/* ", " */" }
  else
    for pieces in string.gmatch(commentstring, "([^%%s]+)") do
      table.insert(comment, pieces)
    end

    -- try to turn block into single line comment
    if blocks[comment[1]] then
      comment = blocks[comment[1]]
    end

    if comment[2] == nil then
      comment[2] = ""
    end
  end

  return comment
end

--- toggle a comment top/ahead of the current line
function M.ToggleCommentAhead()
  local bufnr = vim.api.nvim_get_current_buf()
  local curpos = vim.fn.line(".")
  local comment = vim.pesc(GetComment()[1])
  local lines = vim.api.nvim_buf_get_lines(bufnr, curpos - 2, curpos + 1, false)

  if lines[3]:find(comment) then
    return
  end

  if lines[2]:find("^%s*" .. comment) and not lines[3]:match("^%s*$") then
    lines[3] = lines[3] .. " " .. lines[2]:match("^%s*(.*)")

    vim.api.nvim_buf_set_lines(bufnr, curpos - 2, curpos + 1, false, lines)
    vim.cmd("normal dd")
  elseif lines[2]:find("%S+%s+" .. comment) then
    local comment_text = lines[2]:match(comment .. ".*")
    lines[4] = lines[3]
    lines[3] = lines[2]:match("(.-) " .. comment)
    lines[2] = comment_text

    vim.api.nvim_buf_set_lines(bufnr, curpos - 2, curpos + 1, false, lines)
    vim.cmd("normal ==")
  elseif
    lines[1]:find("^%s*" .. comment)
    and not (lines[2]:find(comment) or lines[2]:match("^%s*$"))
  then
    lines[2] = lines[2] .. " " .. lines[1]:match(comment .. ".*")

    vim.api.nvim_buf_set_lines(bufnr, curpos - 2, curpos + 1, false, lines)
    vim.cmd("normal kdd")
  end
end

--- inserts a comment at the end of the current line
function M.CommentAhead()
  local comment = GetComment()

  local line = vim.api.nvim_get_current_line()
    .. " "
    .. comment[1]
    .. comment[2]

  vim.api.nvim_set_current_line(line)

  -- position the cursor in insert mode
  if comment[2] ~= "" then
    vim.api.nvim_input("A" .. string.rep("<left>", #comment[2]))
  else
    vim.api.nvim_input("A ")
  end
end

-- handles dotrepeat when commenting which does not work with visual mode
-- for visual comments use require'SingleComment'.Comment()
function M.SingleComment()
  vim.go.operatorfunc = "v:lua.require'SingleComment'.Comment"
  return "g@l"
end

--- comments single lines whenever possible
function M.Comment()
  local bufnr = vim.api.nvim_get_current_buf()
  local winnr = vim.api.nvim_get_current_win()
  local comment = GetComment()
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

  -- account for counts
  if count ~= 0 then
    endRow = endRow + count - 1
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, startRow - 1, endRow, false)
  local indent = string.match(lines[1], "^%s*")
  local tmpindent
  local uncomment

  -- check indentation and comment state of all lines for use later
  for i, _ in ipairs(lines) do
    if not lines[i]:match("^%s*$") then
      -- gets the shallowest comment indentation for commenting
      tmpindent = lines[i]:match("^%s*")
      if indent:len() > tmpindent:len() then
        indent = tmpindent
      end

      -- uncomment only when all the lines are commented
      if
        uncomment == nil
        and not lines[i]:match("^" .. indent .. vim.pesc(comment[1]))
      then
        uncomment = true
      end
    end
  end

  -- comment or uncomment all lines
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

  vim.api.nvim_buf_set_lines(bufnr, startRow - 1, endRow, false, lines)
  vim.api.nvim_input("<esc>")
  vim.api.nvim_win_set_cursor(winnr, pos)
end

return M
