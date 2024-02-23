# 🧭 Telescope Lazy Plugins

<!-- panvimdoc-ignore-start -->

![Pull Requests](https://img.shields.io/badge/Pull_Requests-Welcome-a4e400?style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/polirritmico/telescope-lazy-plugins.nvim/main?style=flat-square&color=62d8f1)
![GitHub issues](https://img.shields.io/github/issues/polirritmico/telescope-lazy-plugins.nvim?style=flat-square&color=fc1a70)

<!-- panvimdoc-ignore-end -->

## 🐧 Description

A Telescope picker to quickly access plugins config files for
[lazy.nvim](https://github.com/folke/lazy.nvim) configurations.

⚡ No more head overload trying to remember in which file you changed that
plugin option, or searching through files to check for overlapping
configurations.

Specially useful when your plugin configuration is spread across many files,
when you have a lot of plugins in the same file or when you have multiple
plugins grouped into separate files like this:

```
lua/
└── some/path
    ├── core.lua
    ├── develop.lua
    ├── extras
    │   └── others.lua
    ├── helpers.lua
    ├── misc.lua
    └── ui.lua
```

The plugin check the current `LazyPluginSpec`, extract each plugin data and
generate the full filepath for each. Also, when opening a config file, the
cursor is set at the appropiate position.

<!-- panvimdoc-ignore-start -->

### 📷 Screenshot

![screenshot](https://github.com/polirritmico/telescope-lazy-plugins.nvim/assets/24460484/79fa1730-4861-41a6-8fce-fe1680fb2a0b)

<!-- panvimdoc-ignore-end -->

## 📦 Installation

- Add it into the Telescope dependencies:

```lua
return {
  "nvim-telescope.nvim",
  dependencies = {
    { "polirritmico/telescope-lazy-plugins.nvim" },
  },
  -- etc.
}
```

- Or on its own spec:

```lua
return {
  "polirritmico/telescope-lazy-plugins.nvim",
  dependencies = { "nvim-telescope.nvim" },
  -- etc.
}
```

## 🔍 Usage

- **Command-line:**

```vimscript
:Telescope lazy_plugins
```

- **Lua:**

```lua
require("telescope").extensions.lazy_plugins.lazy_plugins()
```

## 🛠️ Configuration:

Add the options in the `telescope.nvim` opts `extensions` table inside
`lazy_plugins`.

| Option            | Type      | Description                                                                                                                                                                                                                                                                   |
|-------------------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `name_only`       | `boolean` | Match only the repository name. False to match the full `account/repo_name`.                                                                                                                                                                                                  |
| `show_disabled`   | `boolean` | Also show disabled plugins from the Lazy spec.                                                                                                                                                                                                                                |
| `lazy_config`     | `string`  | Path to the lua file containing the lazy `setup()` call. With this option set, search `lazy` and open your `lazy.lua`, `init.lua` or similar file.                                                                                                                            |
| `lazy_spec_table` | `string`  | If plugins are directly passed to the `require("lazy").setup()` function inside a plugins table (instead of using only imports paths), set this option to the file where that table is defined. When no module is found inside a plugin spec this path would be used instead. |

### ⚙️ Full config example:

```lua
return {
  "nvim-telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    {
      "polirritmico/telescope-lazy-plugins.nvim",
      keys = {
        { "<leader>cp", "<Cmd>Telescope lazy_plugins<CR>", desc = "Telescope: Plugins configurations" },
      },
    },
  },
  opts = {
    extensions = {
      lazy_plugins = {
        -- defaults:
        name_only = true,
        show_disabled = true,
        lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua",
        lazy_spec_table = vim.fn.stdpath("config") .. "/lua/config/lazy.lua",
      },
    },
    -- etc.
  },
  -- etc.
```

### ⚙️ Full spec table

When passing the plugin specification table directly to the setup function (e.g.
`require('lazy').setup(spec, opts)`), ensure that the `lazy_spec_table` option
is set to the file where it is defined.

For example:

```lua
-- .conf/nvim/init.lua
local opts = {
  -- lazy configuration options
}
require("lazy").setup({
  -- full list of plugins and configs
  "username/plugin",
  opts = {
    configurations = "values"
  },
  -- etc.
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "polirritmico/telescope-lazy-plugins.nvim" },
    },
    opts = {
      extensions = {
        lazy_plugins = {
          lazy_spec_table = vim.fn.stdpath("config") .. "/init.lua" -- path to this file
        },
      },
    },
  },
}, opts)
```

## 🌱 Contributions

This plugin is made mainly for my personal use, but suggestions, issues, or pull
requests are very welcome.

Enjoy
