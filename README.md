# 🧭 Telescope Lazy Plugins

<!-- panvimdoc-ignore-start -->

![Pull Requests](https://img.shields.io/badge/Pull_Requests-Welcome-a4e400?style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/polirritmico/telescope-lazy-plugins.nvim/main?style=flat-square&color=62d8f1)
![GitHub issues](https://img.shields.io/github/issues/polirritmico/telescope-lazy-plugins.nvim?style=flat-square&color=fc1a70)

<!-- panvimdoc-ignore-end -->

## 🐧 Description

> A [Telescope](https://github.com/nvim-telescope/telescope.nvim) picker to
> quickly access plugins config files for
> [lazy.nvim](https://github.com/folke/lazy.nvim) configurations.

⚡ No more head overload trying to remember in which file you changed that
plugin option, or searching through files to check for overlapping
configurations.

⚡ Quickly open the selected plugin repository webpage in your browser with a
single keystroke (`<C-g>` by default) or its repository local clone directory
(`<C-r>`).

⚡ Add custom entries for your special needs.

The plugin is specially useful when your plugin configuration is spread across
many files, when you have a lot of plugins in the same file or when you have
multiple plugins grouped into separate files like this:

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
cursor is set at the appropriate position.

<!-- panvimdoc-ignore-start -->

### 📷 Screenshot

_Searching for Telescope configurations:_

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

- Load the extension:

```lua
require("telescope").load_extension("lazy_plugins")
```

> Run `:checkhealth telescope` after the installation is recommended (needs to
> be loaded first).

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
| ----------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `lazy_config`     | `string`  | Path to the lua file containing the lazy options passed to the `setup()` call. With this value setted, the `lazy` entry is added, e.g. searching for `lazy` to open `nvim/lua/config/lazy.lua`.                                                                               |
| `lazy_spec_table` | `string`  | If plugins are directly passed to the `require("lazy").setup()` function inside a plugins table (instead of using only imports paths), set this option to the file where that table is defined. When no module is found inside a plugin spec this path would be used instead. |
| `name_only`       | `boolean` | Match only the repository name. False to match the full `account/repo_name`.                                                                                                                                                                                                  |
| `show_disabled`   | `boolean` | Also show disabled plugins from the Lazy spec.                                                                                                                                                                                                                                |
| `picker_opts`     | `table`   | Layout options passed into Telescope. Check `:h telescope.layout`.                                                                                                                                                                                                            |
| `mappings`        | `table`   | Keymaps attached to the picker. See `:h telescope.mappings`.                                                                                                                                                                                                                  |
| `custom_entries`  | `table`   | A collection of custom entries to add into the picker. See the '[Custom Entries](#-custom-entries)' section.                                                                                                                                                                  |

### ⌨️ Mappings

`lp_actions` refers to the table provided by `telescope-lazy-plugins.actions`,
accessible via:

```lua
require("telescope").extensions.lazy_plugins.actions
```

| Insert       | Normal        | lp_actions      | Description                                                                                                                                                                       |
| ------------ | ------------- | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `<CR>`       | `<CR>`        | `open`          | Open the selected plugin config file at the first line of the plugin spec.                                                                                                        |
| `<C-g>`      | `g`           | `open_repo_url` | Open the plugin repository url in your default web browser.                                                                                                                       |
| `<C-r>`      | `r`           | `open_repo_dir` | Open the plugin repository Lazy local clone folder.                                                                                                                               |
| `<LefMouse>` | `<LeftMouse>` | `nothing`       | A dummy function to prevent closing Telescope on mouse clicks. Useful for keeping Telescope open when focus is regained by a mouse click after browsing the plugin documentation. |

### 💈 Custom Entries

Custom entries could be added into the `custom_entries` field in the options.
Should follow this specs:

```lua
---@class LazyPluginsCustomEntry
---@field name string Entry name
---@field filepath string Full path to the lua target file
---@field line? integer Optional: Line number to set the view on the target file. Defaults to 1.
---@field repo_url? string Optional: URL to open with the `open_repo_url` action
---@field repo_dir? string Optional: Directory path to open with the `open_repo_dir` action

--- Example:
{
    name = "custom-entry",
    filepath = vim.fn.stdpath("config") .. "lua/extra-options/somefile.lua",
    -- Optional:
    line = 42,
    repo_url = "https://www.lua.org/manual/5.2/",
    repo_dir = vim.fn.stdpath("config") .. "lua/extra-options/",
}

```

### ⚓ Defaults

```lua
{
  name_only = true, -- match only the `repo_name`, false to match the full `account/repo_name`
  show_disabled = true, -- also show disabled plugins from the Lazy spec.
  lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", -- path to the file containing the lazy opts and setup() call.
  lazy_spec_table = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", -- path to the file containing the lazy plugin spec table.
  custom_entries = {}, ---@type table<LazyPluginsCustomEntry>
  mappings = {
    ["i"] = {
      ["<C-g>"] = lp_actions.open_repo_url,
      ["<C-r>"] = lp_actions.open_repo_dir,
      ["<LeftMouse>"] = lp_actions.nothing,
    },
    ["n"] = {
      ["g"] = lp_actions.open_repo_url,
      ["r"] = lp_actions.open_repo_dir,
      ["<LeftMouse>"] = lp_actions.nothing,
    },
  },
  picker_opts = {
    sorting_strategy = "ascending",
    layout_strategy = "flex",
    layout_config = {
      flex = { flip_columns = 150 },
      horizontal = { preview_width = { 0.55, max = 100, min = 30 } },
      vertical = { preview_cutoff = 20, preview_height = 0.5 },
    },
  },
}
```

## ⚙️ Configuration Examples:

### 🍚 Simple config:

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
        lazy_config = vim.fn.stdpath("config") .. "/lua/lazy/init.lua", -- path to the file containing the lazy opts and setup() call.
      },
    },
    -- etc.
  },
}
```

### 💤 Lazy loading:

Lazy-loading Telescope extensions could be a little tricky. This approach
creates a user auto command that checks when the `telescope.nvim` plugin is
loaded and then executes the `load_extension` function (Could be used in any
Telescope extensions).

<details>
<summary> Click to see the configuration example</summary>

```lua
local load_extension_after_telescope_is_loaded = function(extension_name)
  local lazy_cfg = require("lazy.core.config").plugins
  if lazy_cfg["telescope.nvim"] and lazy_cfg["telescope.nvim"]._.loaded then
    -- if telescope is loaded, then simply load the extension:
    require("telescope").load_extension(extension_name)
  else
    -- If telescope is not loaded, create an autocmd that will load the
    -- extension after telescope is loaded.
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == "telescope.nvim" then
          require("telescope").load_extension(extension_name)
          return true
        end
      end,
    })
  end
end

-- etc.
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      {
        "polirritmico/telescope-lazy-plugins.nvim",
        keys = {
          {
            "<leader>cp",
            "<Cmd>Telescope lazy_plugins<CR>",
            desc = "Telescope: Plugins configurations"
          },
        },
        init = function()
          load_extension_after_telescope_is_loaded("lazy_plugins")
        end,
      },
    },
    -- Add the configuration through the Telescope options:
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
          -- This is not needed. It is just an example of how you can add custom entries.
          custom_entries = {
            {
              name = "custom-entry-example",
              filepath = vim.fn.stdpath("config") .. "/lua/config/mappings.lua",
              repo_url = "https://www.lua.org/manual/5.2/",
              line = 23,
            },
          },
        },
      },
    },
  },
  -- etc.
}
```

</details>

### 📜 Full spec table

When passing the plugin specification table directly to the setup function (e.g.
`require('lazy').setup({...}, opts)`), ensure that the `lazy_spec_table` option
is set pointing to the file where the spec table is defined. For example, for
configurations with a single `init.lua` file:

<details>
<summary> Click to see the configuration example</summary>

```lua
-- Content of file: ~/.conf/nvim/init.lua
local opts = {
  -- Lazy configuration options
}
require("lazy").setup({
  -- full list of plugins and configs like this:
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
          -- Since in this config is only one big table, pass the path of this
          -- file into the `lazy_spec_table` field:
          lazy_spec_table = vim.fn.stdpath("config") .. "/init.lua"
        },
      },
    },
  },
}, opts)
```

</details>

## 🎨 Highlights

This are the highlights defined by **Telescope Lazy Plugins**:

| Highlight group              | Defaults to | Description                      |
| ---------------------------- | ----------- | -------------------------------- |
| TelescopeLazyPlugins         | Normal      | Plugin name                      |
| TelescopeLazyPluginsFile     | Comment     | Module file with the config spec |
| TelescopeLazyPluginsEnabled  | Function    | Enabled plugin icon              |
| TelescopeLazyPluginsDisabled | Delimiter   | Disabled plugin icon             |

## 🌱 Contributions

This plugin is made mainly for my personal use, but suggestions, issues, or pull
requests are very welcome.

**_Enjoy_**
