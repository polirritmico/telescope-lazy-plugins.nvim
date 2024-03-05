# 🧭 Telescope Lazy Plugins

<!-- panvimdoc-ignore-start -->

![Pull Requests](https://img.shields.io/badge/Pull_Requests-Welcome-a4e400?style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/polirritmico/telescope-lazy-plugins.nvim/main?style=flat-square&color=62d8f1)
![GitHub issues](https://img.shields.io/github/issues/polirritmico/telescope-lazy-plugins.nvim?style=flat-square&color=fc1a70)

<!-- panvimdoc-ignore-end -->

## 🐧 Description

> A [Telescope](https://github.com/nvim-telescope/telescope.nvim)  picker to
> quickly access plugins config files for
> [lazy.nvim](https://github.com/folke/lazy.nvim) configurations.

⚡ No more head overload trying to remember in which file you changed that
plugin option, or searching through files to check for overlapping
configurations.

⚡ Quickly open the selected plugin repository webpage in your browser with a
single keystroke (`<C-g>` by default).

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

_Searching for Telescope configs:_

![Screenshot](https://github.com/polirritmico/telescope-lazy-plugins.nvim/assets/24460484/c2ca5c7b-c325-4e32-8aa1-4a014970d1ed)

<!-- panvimdoc-ignore-end -->

## 📦 Installation

- Add it into the Telescope dependencies:

```lua
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "polirritmico/telescope-lazy-plugins.nvim" },
  },
  -- etc.
}
```

> Run `:checkhealth telescope` after the installation is recommended.

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
`lazy_plugins` (check the examples).

| Option            | Type      | Description                                                                                                                                                                                                                                                                   |
|-------------------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `lazy_config`     | `string`  | Path to the lua file containing the lazy options passed to the `setup()` call. With this value setted, the `lazy` entry is added, e.g. searching for `lazy` to open `nvim/lua/config/lazy.lua`.                                                                               |
| `lazy_spec_table` | `string`  | If plugins are directly passed to the `require("lazy").setup()` function inside a plugins table (instead of using only imports paths), set this option to the file where that table is defined. When no module is found inside a plugin spec this path would be used instead. |
| `name_only`       | `boolean` | Match only the repository name. False to match the full `account/repo_name`.                                                                                                                                                                                                  |
| `show_disabled`   | `boolean` | Also show disabled plugins from the Lazy spec.                                                                                                                                                                                                                                |
| `picker_opts`     | `table`   | Layout options passed into Telescope. Check `:h telescope.layout`.                                                                                                                                                                                                            |
| `mappings`        | `table`   | Keymaps attached to the picker. See `:h telescope.mappings`.                                                                                                                                                                                                                  |

## ⌨️ Mappings

`lp_actions` refers to the table provided by `telescope-lazy-plugins.actions`,
accessible via:

```lua
require("telescope").extensions.lazy_plugins.actions
```

| Insert       | Normal        | lp_actions      | Description                                                                                                                                                                       |
|--------------|---------------|-----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `<CR>`       | `<CR>`        | `open`          | Open the selected plugin config file at the first line of the plugin spec.                                                                                                        |
| `<C-g>`      | `g`           | `open_repo_url` | Open the plugin repository url in your default web browser.                                                                                                                       |
| `<LefMouse>` | `<LeftMouse>` | `nothing`       | A dummy function to prevent closing Telescope on mouse clicks. Useful for keeping Telescope open when focus is regained by a mouse click after browsing the plugin documentation. |


### Defaults

```lua
{
  name_only = true, -- match only the `repo_name`, false to match the full `account/repo_name`
  show_disabled = true, -- also show disabled plugins from the Lazy spec.
  lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", -- path to the file containing the lazy opts and setup() call.
  lazy_spec_table = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", -- path to the file containing the lazy plugin spec table.
  picker_opts = {
    sorting_strategy = "ascending",
    layout_strategy = "flex",
    layout_config = {
      flex = { flip_columns = 150 },
      horizontal = { preview_width = { 0.55, max = 100, min = 30 } },
      vertical = { preview_cutoff = 20, preview_height = 0.5 },
    },
  },
  mappings = {
    ["i"] = {
      ["<C-g>"] = lp_actions.open_repo_url,
      ["<LeftMouse>"] = lp_actions.nothing,
    },
    ["n"] = {
      ["g"] = lp_actions.open_repo_url,
      ["<LeftMouse>"] = lp_actions.nothing,
    },
  },
}
```


### ⚙️ Full config example:

```lua
{
  "nvim-telescope/telescope.nvim",
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
        name_only = true,
        show_disabled = true,
        lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", -- path to the file containing the lazy opts and setup() call.
        lazy_spec_table = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", -- path to the file containing the lazy plugin spec table.
        -- This is not needed. It is just an example of how you can customize the picker layout. Check `:h telescope.layout`.
        picker_opts = {
          layout_strategy = "vertical",
          layout_config = {
            vertical = { preview_cutoff = 15, preview_height = 0.5 },
          },
        },
      },
    },
    -- etc.
  },
}
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

## 🎨 Highlights

This are the highlights defined by **Telescope Lazy Plugins**:

| Highlight group              | Defaults to | Description                      |
|------------------------------|-------------|----------------------------------|
| TelescopeLazyPlugins         | Normal      | Plugin name                      |
| TelescopeLazyPluginsFile     | Comment     | Module file with the config spec |
| TelescopeLazyPluginsEnabled  | Function    | Enabled plugin icon              |
| TelescopeLazyPluginsDisabled | Delimiter   | Disabled plugin icon             |

## 🌱 Contributions

This plugin is made mainly for my personal use, but suggestions, issues, or pull
requests are very welcome.

***Enjoy***
