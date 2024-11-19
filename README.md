# SingleComment.nvim

Always single line, comment sensitive, indentation preserving commenting.

Turn on notifications in [Breaking Changes](https://github.com/LucasTavaresA/SingleComment.nvim/issues/3) if using this plugin.

## Contents

- [Features](#features)
- [Installation](#installation)
- [Keybindings](#keybindings)
- [Lazy load it](#lazy-load-it) **Quickstart**

## Features

1. Simple and stupid, just complain and i will change some lua tables around and we are ready to work

2. Supports
   - counts like 5{comment} and dotrepeat
   - commenting in front of the current line, and start a comment on empty lines
   - toggling a comment in front/top of the current line, [preview](#commentahead)
   - pasting as a comment, accounting for indentation
   - block comments in case you really need them, and removing innermost block on cursor,
 	 [preview](#blockcomment)

3. Simplest of them all **~270 loc** in a single file

4. It uses [nvim-ts-context-commentstring](https://github.com/JoosepAlviste/nvim-ts-context-commentstring) automatically if available them tries to turn all results into line comments

5. Single line comments avoid unexpected results when commenting:
   - uncomments only when all the text selected is commented, avoiding confusion
     when getting big blocks of code out of the way for debugging
   - always comments at the most shallow comment to make maintaining different levels of
     commented code easier
   - when you have block comments at the end of lines other plugins fail on
     the simple task of getting this line out of the way, this plugin should **never** fail

## Installation

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "lucastavaresa/SingleComment.nvim",
}
```

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "lucastavaresa/SingleComment.nvim",
}
```

## Keybindings

There is no keybindings by default.

Those are all the available functions:

```lua
-- comments the current line, or a number of lines 5gcc
vim.keymap.set("n", "gcc", require("SingleComment").SingleComment, { expr = true })
-- comments the selected lines
vim.keymap.set("v", "gcc", require("SingleComment").Comment, {})
-- toggle a comment top/ahead of the current line
vim.keymap.set("n", "gca", require("SingleComment").ToggleCommentAhead, {})
-- comments ahead of the current line
vim.keymap.set("n", "gcA", require("SingleComment").CommentAhead, {})
-- comment a block, and removes the innermost block comment in normal mode
vim.keymap.set({ "n", "v" }, "gcb", require("SingleComment").BlockComment)
-- pastes as a comment, accounting for indentation
vim.keymap.set({ "n", "v" }, "gcp", require("SingleComment").CommentPaste)
```

## Utilities

### GetComment()

Get a table with comment beginning and end

Improved by ts-context-commentstring but also works without it automatically,
them gets single-lined/tweaked by this plugin custom tables

Useful for custom utility functions that need accurate comment detection

```lua
-- you can pass "block", and it will *try* to get block comments
local comment = require("SingleComment").GetComment()
```

## Lazy load it

Those commands substitute all the above

- with packer **i did not test this, please inform me if it works** :)

```lua
  use {
    "lucastavaresa/SingleComment.nvim",
    opt = true,
    keybindings = {
      { { "n", "v" }, "gcc" }, { "n", "gca" }, { "n", "gcA" },
      { { "n", "v" }, "gcb" }, { { "n", "v" }, "gcp" }
    },
    requires = {
      "nvim-treesitter/nvim-treesitter",
      "JoosepAlviste/nvim-ts-context-commentstring"
    },
    setup = function()
      vim.keymap.set(
        "n",
        "gcc",
        require("SingleComment").SingleComment,
        { expr = true }
      )
      vim.keymap.set("v", "gcc", require("SingleComment").Comment, {})
      vim.keymap.set("n", "gca", require("SingleComment").ToggleCommentAhead, {})
      vim.keymap.set("n", "gcA", require("SingleComment").CommentAhead, {})
      vim.keymap.set({ "n", "v" }, "gcb", require("SingleComment").BlockComment)
      vim.keymap.set({ "n", "v" }, "gcp", require("SingleComment").CommentPaste)
    end
  }
```

- with lazy:

```lua
  {
    "lucastavaresa/SingleComment.nvim",
    lazy = true,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "JoosepAlviste/nvim-ts-context-commentstring"
    },
    init = function()
      vim.keymap.set("n", "gcc", require("SingleComment").SingleComment, { expr = true })
      vim.keymap.set("v", "gcc", require("SingleComment").Comment, {})
      vim.keymap.set("n", "gca", require("SingleComment").ToggleCommentAhead, {})
      vim.keymap.set("n", "gcA", require("SingleComment").CommentAhead, {})
      vim.keymap.set({ "n", "v" }, "gcb", require("SingleComment").BlockComment)
      vim.keymap.set({ "n", "v" }, "gcp", require("SingleComment").CommentPaste)
    end,
  },
```

## CommentAhead

[![asciicast](https://asciinema.org/a/jChjT4OZBaj7WsKWsAWiKsI3F.svg)](https://asciinema.org/a/jChjT4OZBaj7WsKWsAWiKsI3F)

## BlockComment

[![asciicast](https://asciinema.org/a/2VtZyh0Q3Nb5Eytwo0RSp5c2G.svg)](https://asciinema.org/a/2VtZyh0Q3Nb5Eytwo0RSp5c2G)

## Other Comment plugins

- [echasnovski/mini.comment](https://github.com/echasnovski/mini.comment)
- [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim)
- [preservim/nerdcommenter](https://github.com/preservim/nerdcommenter)
- [tpope/vim-commentary](https://github.com/tpope/vim-commentary)
- [b3nj5m1n/kommentary](https://github.com/b3nj5m1n/kommentary)
