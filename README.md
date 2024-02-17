# Telescope Lazy Plugins

<!-- panvimdoc-ignore-start -->

![Pull Requests](https://img.shields.io/badge/Pull_Requests-Welcome-a4e400?style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/polirritmico/telescope-lazy-plugins.nvim/main?style=flat-square&color=62d8f1)
![GitHub issues](https://img.shields.io/github/issues/polirritmico/telescope-lazy-plugins.nvim?style=flat-square&color=fc1a70)

<!-- panvimdoc-ignore-end -->

## Description

<!-- panvimdoc-ignore-start -->
<!-- panvimdoc-ignore-end -->

A Telescope picker to quickly access the plugins config files loaded into the
Lazy spec. Specially useful if you have multiple plugins grouped into separate
files like this:

```
lua/
└── plugins
    ├── core.lua
    ├── develop.lua
    ├── extras
    │   └── others.lua
    ├── helpers.lua
    ├── misc.lua
    └── ui.lua
```

The plugin check the current `LazyPluginSpec`, extract each plugin data and
generate the full filepath for each. When opening a config file, the cursor is
focused on the first line of the plugin config.

## Installation

- Add it into the Telescope dependencies:

```lua
return {
  "nvim-telescope.nvim",
  dependencies = {
    { "polirritmico/telescope-lazy-plugins" },
  },
  -- etc.
}
```

## Usage

### command-line:

```vimscript
:Telescope lazy_plugins<CR>
```

### lua:

```lua
require("telescope").extensions.lazy_plugins.lazy_plugins()
```

## Full config example:

```lua
return {
  "nvim-telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    -- etc.
    {
      "polirritmico/telescope-lazy-plugins",
      -- defaults:
      opts = {
        name_only = true, -- Match only the `repo_name`, false to match the full `account/repo_name`
        show_disabled = true, -- Also show disabled plugins from the Lazy spec.
        lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", -- Optional. Path to the lua file containing the lazy `setup()` call
      },
    },
    keys = {
      { "<leader>cp", "<Cmd>Telescope lazy_plugins<CR>", desc = "Telescope: Plugins configurations" },
    }
  },
  -- etc.
```
