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
  nelua = { "-- ", "" },
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
  local winnr = vim.api.nvim_get_current_win()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local comment = vim.pesc(GetComment()[1])
  local col = vim.fn.col(".") - 1
  local c = vim.fn.line(".")
  local t = c - 1
  local b = c + 1
  local feedlines = ""

  if
    lines[b] ~= nil
    and lines[c]:find("^%s*" .. comment)
    and not (lines[b]:match(comment) or lines[b]:match("^%s*$"))
  then
    lines[c] = lines[b] .. " " .. lines[c]:match("^%s*(.*)")
    table.remove(lines, b)
  elseif lines[c]:find("%S+%s+" .. comment) then
    local text, comment_text = lines[c]:match("(.*) (" .. comment .. ".*)")
    table.insert(lines, c, comment_text)
    lines[c + 1] = text
    feedlines = "==zv"
  elseif
    lines[t] ~= nil
    and lines[t]:find("^%s*" .. comment)
    and not (lines[c]:find(comment) or lines[c]:match("^%s*$"))
  then
    lines[c] = lines[c] .. " " .. lines[t]:match(comment .. ".*")
    table.remove(lines, t)
    c = c - 1
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(winnr, { c, col })
  vim.api.nvim_feedkeys(feedlines, "n", false)
end

--- inserts a comment at the end of the current line
function M.CommentAhead()
  local comment = GetComment()
  local line = vim.api.nvim_get_current_line()

  if line ~= "" then
    line = line .. " "
  end

  vim.api.nvim_set_current_line(line .. comment[1] .. comment[2])
  vim.api.nvim_input("==")

  -- position the cursor in insert mode
  if comment[2] == "" then
    vim.api.nvim_input("A ")
  else
    vim.api.nvim_input("A" .. string.rep("<left>", #comment[2]))
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

  -- in case the selection starts from the bottom
  if startRow > endRow then
    startRow, endRow = endRow, startRow
  end

  -- account for counts
  if count ~= 0 then
    endRow = endRow + count - 1
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, startRow - 1, endRow, false)
  local indent = string.match(lines[1], "^%s*")
  local tmpindent
  local uncomment

  if #lines == 1 and (lines[1] == nil or lines[1] == "") then
    --- comment when used in a single empty line
    lines[1] = comment[1] .. comment[2]

    vim.api.nvim_buf_set_lines(bufnr, startRow - 1, endRow, false, lines)
    vim.api.nvim_input("==")

    -- position the cursor in insert mode
    if comment[2] == "" then
      vim.api.nvim_input("A ")
    else
      vim.api.nvim_input("A" .. string.rep("<left>", #comment[2]))
    end
  else
    --- comment when used in multiple lines

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
    vim.api.nvim_win_set_cursor(winnr, { startRow, col })
  end
end

return M
