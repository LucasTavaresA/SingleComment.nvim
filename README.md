# SingleComment.nvim

Super simple comment plugin that always uses single line comments

## Contents

- [Features](#features)
- [Installation](#installation)
- [Keybindings](#keybindings)
- [Lazy load it](#lazy-load-it) **Quickstart**

## Features

1. Supports counts like 5{comment} and commenting in front of the current line

2. Simplest plugin of them all **~100 loc**, has all the fancy features

3. Compatible with [nvim-ts-context-commentstring](https://github.com/JoosepAlviste/nvim-ts-context-commentstring), turns its results into single line comments,
   **See how to enable it below**

4. Single line comments avoid unexpected results when commenting:
   - uncomments only when all the text selected is commented, avoiding confusion
     when getting big blocks of code out of the way for debugging
   - always comments at the most shallow comment avoiding weird indentation
     issues
   - when you have block comments at the end of lines other plugins fail on
     the simple task of getting this line out of the way, this plugin will **never** fail

- i need help to make it dot repeatable 🥺

## Installation

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  "lucastavaresa/SingleComment.nvim",
  -- requires = "JoosepAlviste/nvim-ts-context-commentstring", -- ts-context-commentstring support
  setup = function()
    -- vim.g.SC_ts_context = true -- ts-context-commentstring support
  end
}
```

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "lucastavaresa/SingleComment.nvim",
  -- dependencies = "JoosepAlviste/nvim-ts-context-commentstring", -- ts-context-commentstring support
  init = function()
    -- vim.g.SC_ts_context = true -- ts-context-commentstring support
  end
}
```

## Keybindings

You need to set those to use SingleComment.nvim

Those are all the available functions:

```lua
vim.keymap.set({ "n", "v" }, "gcc", require("SingleComment").SingleComment)
vim.keymap.set("n", "gca", require("SingleComment").SingleCommentAhead)
```

## Lazy load it

Those commands substitute all the above

- with packer **i did not test this, please inform me if it works** :)

```lua
  use {
    "lucastavaresa/SingleComment.nvim",
    opt = true,
    keybindings = { { { "n", "v" }, "gcc" }, { "n", "gca" } },
    requires = "JoosepAlviste/nvim-ts-context-commentstring", -- ts-context-commentstring support
    setup = function()
      vim.g.SC_ts_context = true -- ts-context-commentstring support
      vim.keymap.set({ "n", "v" }, "gcc", require("SingleComment").SingleComment)
      vim.keymap.set("n", "gca", require("SingleComment").SingleCommentAhead)
    end
  }
```

- with lazy:

```lua
  {
    "lucastavaresa/SingleComment.nvim",
    lazy = true,
    dependencies = "JoosepAlviste/nvim-ts-context-commentstring", -- ts-context-commentstring support
    init = function()
      vim.g.SC_ts_context = true -- ts-context-commentstring support
    end,
    keys = {
      {
        "gcc",
        function()
          require("SingleComment").SingleComment()
        end,
        mode = { "n", "v" },
      },
      {
        "gca",
        function()
          require("SingleComment").SingleCommentAhead()
        end,
      },
    },
  },
```
