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

## TODO

- [ ] Add config
- [ ] Improve picker results

## Installation

- Add it into the Telescope dependencies:

```lua
return {
  "nvim-telescope.nvim",
  dependencies = {
    { "polirritmico/telescope-lazy-plugins" },
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
    {
      "polirritmico/telescope-lazy-plugins",
      opts = {
        lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua" -- nil, or the path to the file containing the require("lazy").setup(spec, otps)
        disabled_plugins = true, -- Add or not the disabled plugins into the picker
        full_repo_name_match = false, -- true match only the `plugin_name`, false match the `username/plugin_name`
      },
    },
    keys = {
      { "<leader>cc", "<Cmd>Telescope lazy_plugins<CR>", desc = "Telescope: Plugins configurations" },
    }
  },
  -- etc.
```

## Manually load the Telescope extension:

```lua
:lua require("telescope").load_extension("lazy_plugins")
```

