local M = {}

---@type table kinds of comments
-- stylua: ignore
local comments = {
  ---@type table lines and filetypes that can be changed to block comments
  -- some can't be changed ;-; but are here for format adjustments
  block = {
    ["<!--"]        = { "<!-- ", " -->" },
    ["--[["]        = { "--[[ ", " ]]" },
    ["-- "]         = { "--[[ ", " ]]" },
    ["--"]          = { "--[[ ", " ]]" },
    ["/*"]          = { "/* ",   " */" },
    lisp            = { "#| ",   " |#" },
    cmake           = { "#[[ ",  " ]]" },
    haskell         = { "{- ",   " -}" },
    elm             = { "{- ",   " -}" },
    julia           = { "#= ",   " =#" },
    luau            = { "--[[ ", " ]]" },
    nim             = { "#[ ",   " ]#" },
    ocaml           = { "(* ",   " *)" },
    fsharp          = { "(* ",   " *)" },
    markdown        = { "<!-- ", " -->" },
    org             = { "# ",    "" },
    neorg           = { "# ",    "" },
    javascript      = { "/* ",   " */" },
    c               = { "/* ",   " */" },
    editorconfig    = { "# ",   "" },
    fortran         = { "! ",   "" },
    default         = { "/* ",   " */" },
  },
  ---@type table blocks and filetypes that can be changed to line comments
  -- some can't be changed ;-; but are here for format adjustments
  line = {
    ["<!--"]        = { "<!-- ", " -->" },
    ["/*"]          = { "// ",   "" },
    ["/* "]         = { "// ",   "" },
    [";"]           = { "; ",   "" },
    ["%"]           = { "% ",    "" },
    ['#']           = { "# ",    "" },
    nim             = { "# ",    "" },
    json            = { "// ",   "" },
    jsonc           = { "// ",   "" },
    nelua           = { "-- ",   "" },
    luau            = { "-- ",   "" },
    ocaml           = { "(* ",   " *)" },
    css             = { "/* ",   " */" },
    markdown        = { "<!-- ", " -->" },
    org             = { "# ",    "" },
    neorg           = { "# ",    "" },
    editorconfig    = { "# ",   "" },
    fortran         = { "! ",   "" },
    default         = { "// ",   "" },
  },
}

---@param kind? string kind of returned comment, defaults to "line"
---@return table table with the comment beginning/end
function M.GetComment(kind)
  kind = kind or "line"
  local comment = {}
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

  local ok, tsc = pcall(require, "ts_context_commentstring.internal")

  if ok then
    tsc.update_commentstring({})
  end

  local cs = vim.api.nvim_buf_get_option(bufnr, "commentstring")

  if comments[kind][filetype] ~= nil then
    -- use [filetype] override
    comment = comments[kind][filetype]
  elseif cs == "" or cs == nil then
    -- use [default] comment for [kind]
    comment = comments[kind]["default"]
  else
    -- separating strings like `%%s` like tex comments
    -- does not work well in a for loop with gmatch
    comment[1] = cs:match("(.*)%%s")
    comment[2] = cs:match("%%s(.*)")

    -- use a better [kind] of comment, or adjust its format
    if comments[kind][comment[1]] then
      comment = comments[kind][comment[1]]
    end

    if comment[1] == nil then
      comment[1] = ""
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
  local comment = vim.pesc(M.GetComment()[1])
  local col = vim.fn.col(".") - 1
  local c = vim.fn.line(".")
  local t = c - 1
  local b = c + 1
  local after_cmd = ""

  if
    lines[b]
    and lines[c]:find("^%s*" .. comment)
    and not (lines[b]:match(comment) or lines[b]:match("^%s*$"))
  then
    -- move current line comment ahead of bottom line
    lines[c] = lines[b] .. " " .. lines[c]:match("^%s*(.*)")
    table.remove(lines, b)
  elseif lines[c]:find("%S+%s+" .. comment) then
    -- move comment ahead of current line to a new line on top
    local text, comment_text = lines[c]:match("(.*) (" .. comment .. ".*)")
    table.insert(lines, c, comment_text)
    lines[c + 1] = text
    after_cmd = "==zv"
  elseif
    lines[t]
    and lines[t]:find("^%s*" .. comment)
    and not (lines[c]:find(comment) or lines[c]:match("^%s*$"))
  then
    -- move top line comment ahead of current line
    lines[c] = lines[c] .. " " .. lines[t]:match(comment .. ".*")
    table.remove(lines, t)
    c = c - 1
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(winnr, { c, col })
  vim.api.nvim_feedkeys(after_cmd, "n", false)
end

--- inserts a comment at the end of the current line
function M.CommentAhead()
  local comment = M.GetComment()
  local line = vim.api.nvim_get_current_line()
  -- position the cursor in insert mode
  local position = vim.api.nvim_replace_termcodes(
    string.rep("<left>", #comment[2]),
    true,
    false,
    true
  )

  if line:match("^%s*$") then
    -- comment on empty/only-space line
    vim.api.nvim_feedkeys(
      "S" .. comment[1] .. comment[2] .. position,
      "n",
      false
    )
  else
    -- comment in ahead of the line
    vim.api.nvim_feedkeys(
      "A " .. comment[1] .. comment[2] .. position,
      "n",
      false
    )
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
  local comment = M.GetComment()
  local count = vim.v.count
  local _, sr, sc, _ = unpack(vim.fn.getpos("."))
  local _, er, ec, _ = unpack(vim.fn.getpos("v"))
  local mode = vim.api.nvim_get_mode()["mode"]

  -- in case the selection is reversed
  if sr > er then
    sr, er = er, sr
  end
  if sc > ec then
    sc, ec = ec, sc
  end

  -- account for counts
  if count ~= 0 then
    er = er + count - 1
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, sr - 1, er, false)

  if #lines == 1 and (lines[1] == nil or lines[1] == "") then
    --- comment when used in a single empty line
    M.CommentAhead()
    return
  end

  --- comment when used in multiple lines
  local indent = lines[1]:match("^%s*")
  local tmpindent, uncomment

  -- check indentation and comment state of all lines for use later
  for i, _ in ipairs(lines) do
    if not lines[i]:match("^%s*$") then
      -- gets the shallowest comment indentation for commenting
      tmpindent = lines[i]:match("^%s*")
      if #indent > #tmpindent then
        indent = tmpindent
      end

      -- uncomment only when all the lines are commented
      if
        uncomment == nil and not lines[i]:match("^%s*" .. vim.pesc(comment[1]))
      then
        uncomment = true
      end
    end
  end

  -- comment or uncomment all lines
  for i, _ in ipairs(lines) do
    if mode == "\x16" then
      lines[i] =
          lines[i]:sub(1, sc - 1)
          .. comment[1]
          .. lines[i]:sub(sc, ec)
          .. comment[2]
          .. lines[i]:sub(ec + 1)
    elseif not lines[i]:match("^%s*$") then
      lines[i] = lines[i]:gsub("^" .. indent, "")

      if uncomment then
        lines[i] = indent .. comment[1] .. lines[i] .. comment[2]
      else
        lines[i] = lines[i]
          :gsub("^" .. vim.pesc(comment[1]), indent)
          :gsub(vim.pesc(comment[2]) .. "$", "")
      end
    end
  end

  vim.api.nvim_buf_set_lines(bufnr, sr - 1, er, false, lines)
  vim.api.nvim_input("<esc>")
  vim.api.nvim_win_set_cursor(winnr, { sr, sc - 1 })
end

function M.BlockComment()
  local bufnr = vim.api.nvim_get_current_buf()
  local mode = vim.api.nvim_get_mode()["mode"]
  local comment = M.GetComment("block")
  local _, sr, sc, _ = unpack(vim.fn.getpos("."))
  local _, er, ec, _ = unpack(vim.fn.getpos("v"))
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  if mode == "v" or mode == "V" or mode == "\x16" then
    -- keep start/end in the right place in reverse selection
    if sr > er then
      sr, er = er, sr
      sc, ec = ec, sc
    end

    -- get all the line in visual line mode
    if mode == "V" then
      sc, ec = 1, 999
    end

    if sr == er then
      -- cursor in the same line
      -- in case of reversed column
      if sc > ec then
        sc, ec = ec, sc
      end

      lines[sr] = lines[sr]:sub(1, sc - 1)
        .. " "
        .. comment[1]
        .. lines[sr]:sub(sc, ec):gsub("^%s+", "")
        .. comment[2]
        .. (#lines[sr]:sub(ec + 1) > 0 and " " .. lines[er]:sub(ec + 1) or "")
    else
      -- cursor in separate lines
      lines[sr] = lines[sr]:sub(1, sc - 1)
        .. " "
        .. comment[1]
        .. lines[sr]:sub(sc):gsub("^%s+", "")

      lines[er] = lines[er]:sub(1, ec)
        .. comment[2]
        .. (#lines[er]:sub(ec + 1) > 0 and " " .. lines[er]:sub(ec + 1) or "")
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_feedkeys("=", "n", false)
  else
    -- uncomment innermost comment
    comment = { vim.pesc(comment[1]), vim.pesc(comment[2]) }

    for i = sr, 1, -1 do
      if lines[i]:find(comment[1]) then
        lines[i] = lines[i]:gsub("^(%s*)" .. comment[1], "%1")
        lines[i] = lines[i]:gsub("%s" .. comment[1], "")

        for j = sr, #lines do
          if lines[j]:find(comment[2]) then
            lines[j] = lines[j]:gsub(comment[2] .. "%s?", "")

            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
            return
          end
        end
      end
    end
  end
end

return M
