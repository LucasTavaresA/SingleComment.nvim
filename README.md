# SingleComment.nvim

Super simple comment plugin that always uses single line comments

## Contents

- [Features](#features)
- [Installation](#installation)
- [Keybindings](#keybindings)
- [Lazy load it](#lazy-load-it) **Quickstart**

## Features

1. Always comments single lines, **Never get confused again** XD

2. Supports counts like 5gcc and commenting in front of the current line

3. Simplest plugin of them all, it uses a single function for everything, no
   fancy features, can be lazy-loaded very easily

4. Has great language support with a lua table made by hand, this is empowered by single line comments,
   **please help adding more languages**

## Installation

[packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use "lucastavaresa/SingleComment.nvim"
```

[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
"lucastavaresa/SingleComment.nvim"
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
    setup = function()
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
