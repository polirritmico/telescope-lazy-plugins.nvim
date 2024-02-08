# Telescope Lazy Plugins

A Telescope picker to quickly access the plugins config files loaded into the
Lazy spec. Specially useful if you have multiple plugins grouped into multiple
files like this:

```
plugins/
├── core.lua
├── develop.lua
├── extras.lua
├── helpers.lua
├── misc.lua
└── ui.lua
```

The plugin check the `LazyPluginSpec`, extract each plugin data and generate the
full filepath for each. When opening each config file, the cursor is setted to
the first line of the plugin config.

## Installation

- Add it into the Telescope dependencies:

```lua
return {
  "nvim-telescope.nvim",
  dependencies = {
    { "polirritmico/telescope-lazy-plugin" },
  },
  -- Etc.
}
```

## Usage

From the command-line:

```vimscript
:Telescope lazy_plugins<CR>
```

## Full Lazy config:

```lua
return {
  "nvim-telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    -- etc.
    { "polirritmico/telescope-lazy-plugin" },
  },
  keys = {
    { "<leader>cc", "<Cmd>Telescope lazy_plugins<CR>", desc = "Telescope: Plugins configurations" },
  }
  -- etc.
```

## Manually load the Telescope extension:

```lua
:lua require("telescope").load_extension("lazy_plugins")
```

