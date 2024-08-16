# 🧭 Telescope Lazy Plugins

<!-- panvimdoc-ignore-start -->

[![Pull Requests](https://img.shields.io/badge/Pull_Requests-Welcome-a4e400?style=flat-square)](https://github.com/polirritmico/telescope-lazy-plugins.nvim/pulls)
[![GitHub issues](https://img.shields.io/github/issues/polirritmico/telescope-lazy-plugins.nvim?style=flat-square&color=fc1a70)](https://github.com/polirritmico/telescope-lazy-plugins.nvim/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/polirritmico/telescope-lazy-plugins.nvim/main?style=flat-square&color=62d8f1)](https://github.com/polirritmico/telescope-lazy-plugins.nvim/commits/main/)

<!-- panvimdoc-ignore-end -->

## 🐧 Description

> A [Telescope](https://github.com/nvim-telescope/telescope.nvim) picker to
> quickly access configurations of plugins managed by
> [lazy.nvim](https://github.com/folke/lazy.nvim).

<!-- panvimdoc-ignore-start -->

### 📷 Screenshot

_Example: Searching for `telescope` plugins configurations:_

![Screenshot](https://github.com/polirritmico/telescope-lazy-plugins.nvim/assets/24460484/c2ca5c7b-c325-4e32-8aa1-4a014970d1ed)

<!-- panvimdoc-ignore-end -->

### ✨ Features

⚡ Simply search the plugin name and open its configuration at the corresponding
file and line.

⚡ Quickly access all the specs where a plugin is defined.

⚡ No more head overload trying to remember in which file you changed that
plugin option.

⚡ Easily find duplicates or conflicting overlapping settings.

⚡ Add custom entries to any file for your special needs.

⚡ Quickly execute builtin actions on the selected entry:

- Open the selected plugin configuration (`<CR>`).
- Open the selected plugin webpage in a browser (`<C-g>x`).
- Open the selected plugin README file (`<C-g>r`).
- Open the selected plugin repository local clone directory (`<C-g>d`).
- Open a `live_grep` picker at the plugin's local directory path (`<C-g>l`).
- Open a `find_files` picker at the plugin's local directory path (`<C-g>f`).
- Create/Add your custom actions.

## 📌 Requirements

- Neovim >= v0.9.0
- lazy.nvim >= v10.24.3

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

Check the [Configuration examples](#-simple-config) and the
[Configuration section](#-configuration) for more details.

<!-- prettier-ignore-start -->
> [!IMPORTANT]
> 📌 If your lazy configuration file is not located in the default path
> (`nvim/lua/config/lazy.lua`), the `lazy_config` option must be set to a valid
> path.
<!-- prettier-ignore-end -->

- Manually loading the extension:

```lua
require("telescope").load_extension("lazy_plugins")
```

<!-- prettier-ignore-start -->
> [!TIP]
> It's recommended to run `:checkhealth telescope` after the installation (make
> sure the extension is loaded first).
<!-- prettier-ignore-end -->

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
`lazy_plugins` ([configuration examples](#-simple-config)).

| Option           | Type      | Description                                                                                                                                                                                                                                                                   |
| ---------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `lazy_config`    | `string`  | Path to the lua file containing the lazy options passed to the `setup()` call. This is the first-level imported file and the one you would be directed by searching `lazy.nvim`. **Should be set if the lazy.nvim config file path differs from the [defaults](#-defaults)**. |
| `name_only`      | `boolean` | Match only the repository name. Set to `false` to match the full `account/repo_name`.                                                                                                                                                                                         |
| `show_disabled`  | `boolean` | Also show disabled plugins from the Lazy spec.                                                                                                                                                                                                                                |
| `ignore_imports` | `table`   | Array-like string table with modules to ignore. Useful for config distributions like LazyVim to avoid importing the inner configurations, e.g., `{ "lazyvim.plugins" }`.                                                                                                      |
| `picker_opts`    | `table`   | Telescope layout options passed to the picker. Check `:h telescope.layout`.                                                                                                                                                                                                   |
| `mappings`       | `table`   | Keymaps attached to the picker. See `:h telescope.mappings`. Also, '[Custom Actions](#-custom-actions)' could be added.                                                                                                                                                       |
| `live_grep`      | `table`   | Custom options to be used by the `live_grep` picker action (`<C-g>l`). See `:h telescope.builtin.live_grep`.                                                                                                                                                                  |
| `custom_entries` | `table`   | A collection of custom entries to add into the picker. See the '[Custom Entries](#-custom-entries)' section.                                                                                                                                                                  |

### ⌨️ Mappings

In next table, the `lp_actions` column refers to the name of the action function
provided by the module `telescope-lazy-plugins.actions`, accessible via:

```lua
require("telescope").extensions.lazy_plugins.actions
```

| Insert mode | Normal mode | lp_actions             | Description                                                                                   |
| ----------- | ----------- | ---------------------- | --------------------------------------------------------------------------------------------- |
| `<CR>`      | `<CR>`      | `open`                 | Open the selected plugin config file at the first line of the plugin spec.                    |
| `<C-g>d`    | `gd`        | `open_repo_dir`        | Open the local clone folder of the plugin repository.                                         |
| `<C-g>f`    | `gf`        | `open_repo_find_files` | Open a Telescope `find_files` picker at the repository local clone directory path.            |
| `<C-g>l`    | `gl`        | `open_repo_live_grep`  | Open a Telescope `live_grep` picker at the repository local clone directory path.             |
| `<C-g>r`    | `gr`        | `open_readme`          | Open the selected plugin README file.                                                         |
| `<C-g>x`    | `gx`        | `open_repo_url`        | Open the plugin repository url in the default web browser.                                    |
|             |             | `custom_action`        | A wrapper helper to use custom actions. See the '[Custom Actions](#-custom-actions)' section. |

### ⚓ Defaults

<details>
<summary> Click to see the configuration spec </summary>

```lua
---@class TelescopeLazyPluginsConfig
---@field lazy_config string? Path to the file containing the lazy opts and setup() call
---@field mappings table Keymaps attached to the picker. See `:h telescope.mappings`
---@field name_only boolean Match only the `repo_name`, false to match the full `account/repo_name`
---@field picker_opts table Layout options passed into Telescope. Check `:h telescope.layout`
---@field show_disabled boolean Also show disabled plugins from the Lazy spec
---@field custom_entries? table<LazyPluginsCustomEntry|LazyPluginsData> Table to pass custom entries to the picker.
---@field live_grep? table Options to pass into the `live_grep` telescope builtin picker
---@field ignore_imports? string[]|table<string, boolean> Array of imports to ignore
```

</details>

```lua
{
  lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", -- This must be a valid path to the file containing the lazy opts and setup() call.
  name_only = true, -- match only the `repo_name`, false to match the full `account/repo_name`.
  show_disabled = true, -- also show disabled plugins from the Lazy spec.
  custom_entries = {}, ---@type table<LazyPluginsCustomEntry> Table to pass custom entries to the picker.
  live_grep = {}, -- Opts to pass into `live_grep`. Check `:h telescope.builtin.live_grep`.
  ignore_imports = {}, -- Add imports you want to ignore, e.g., "lazyvim.plugins".
  mappings = {
    ["i"] = {
      ["<C-g>d"] = lp_actions.open_repo_dir,
      ["<C-g>f"] = lp_actions.open_repo_find_files,
      ["<C-g>l"] = lp_actions.open_repo_live_grep,
      ["<C-g>r"] = lp_actions.open_readme,
      ["<C-g>x"] = lp_actions.open_repo_url,
    },
    ["n"] = {
      ["gd"] = lp_actions.open_repo_dir,
      ["gf"] = lp_actions.open_repo_find_files,
      ["gl"] = lp_actions.open_repo_live_grep,
      ["gr"] = lp_actions.open_readme,
      ["gx"] = lp_actions.open_repo_url,
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
        lazy_config = vim.fn.stdpath("config") .. "/lua/lazy/init.lua", -- Must be a valid path to the file containing the lazy spec and setup() call.
      },
    },
    -- etc.
  },
}
```

### 💤 Lazy loading:

Lazy-loading Telescope extensions could be a little tricky. This approach
creates a user auto command that checks when the `telescope.nvim` plugin is
loaded and then executes the `load_extension` function (Could be used with any
Telescope extension).

<!-- panvimdoc-ignore-start -->
<details>
<summary> Click to see the configuration example</summary>
<!-- panvimdoc-ignore-end -->

Lazy loader utility function:

```lua
local load_extension_after_telescope_is_loaded = function(extension_name)
  local lazy_cfg = require("lazy.core.config").plugins
  if lazy_cfg["telescope.nvim"] and lazy_cfg["telescope.nvim"]._.loaded then
    -- Since Telescope is loaded, just load the extension:
    require("telescope").load_extension(extension_name)
  else
    -- If Telescope is not loaded, create an autocmd that will load the
    -- extension after Telescope is loaded.
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
```

Usage:

```lua
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      {
        "polirritmico/telescope-lazy-plugins.nvim",
        init = function()
          load_extension_after_telescope_is_loaded("lazy_plugins")
        end,
      },
    },
    keys = {
      {"<leader>cp", "<Cmd>Telescope lazy_plugins<CR>", desc = "Telescope: Plugins configurations"},
    },
    -- Add the plugin configuration through the Telescope extensions options:
    opts = {
      extensions = {
        lazy_plugins = {
          show_disabled = true,
          lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua", -- path to the file containing the lazy opts and setup() call.
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
              line = 23, -- Open the file with the cursor in this line
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

If your plugins are inside a large table passed directly to the
`require('lazy').setup({...}, opts)` call, make sure to set the `lazy_config`
option to specify the file where the spec table is defined. For example, for
configurations in a single `init.lua` file:

<!-- panvimdoc-ignore-start -->
<details>
<summary> Click to see the configuration example</summary>
<!-- panvimdoc-ignore-end -->

```lua
-- Content of file: ~/.conf/nvim/init.lua
local opts = {
  -- Lazy configuration options
}
require("lazy").setup({
  -- full list of plugins and configs like this:
  "username/a_plugin",
  opts = {
    configurations = "custom values",
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
          -- Set the path of this file (~/.config/nvim/init.lua) into the `lazy_config` field:
          lazy_config = vim.fn.stdpath("config") .. "/init.lua"
        },
      },
    },
  },
}, opts)
```

</details>

## 💻 Advanced Features

### 🔧 Custom Actions

The plugin also offer the possibility to add and define your custom actions to
the picker through `custom_action` and helper functions.

<!-- panvimdoc-ignore-start -->
<details>
<summary> Click to see the functions details</summary>
<!-- panvimdoc-ignore-end -->

---

**Helper Functions:**

- **append_to_telescope_history:**

Append the search to the Telescope history, allowing it to be reopened with
`:Telescope resume`.

| Inputs/Output    | Type    | Description                   |
| ---------------- | ------- | ----------------------------- |
| `prompt_bufnr`   | integer | Telescope prompt buffer value |
| return: `output` | nil     |                               |

- **custom_action:**

A wrapper function to use custom actions. This function get and validates the
selected entry field, executes the passed `custom_function` in a protected call
and returns its output.

| Inputs/Output     | Type     | Description                                                                                                                                                                               |
| ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `prompt_bufnr`    | integer  | Telescope prompt buffer value                                                                                                                                                             |
| `field`           | string   | Field of the `LazyPluginsData` to validate the selected entry (before the `custom_function` call). Check the '[Custom Entries](#-custom-entries)' section for details on the entry field. |
| `custom_function` | function | Custom function to execute, e.g., `foo(bufnr, entry, custom_args)`. Check the custom action example.                                                                                      |
| `args`            | table?   | Custom args if needed.                                                                                                                                                                    |
| return: `output`  | any      | The output of the custom_function, nil or the error object from pcall.                                                                                                                    |

</details>

#### Examples:

<!-- panvimdoc-ignore-start -->
<details>
<summary> Click to see a custom action example</summary>
<!-- panvimdoc-ignore-end -->

This example shows a message that displays the repository local clone path of
the selected plugin entry.

Use `custom_action` to access the selected entry and execute a custom function:

```lua
--- The example function
---@param bufnr integer passed by the telescope mapping execution call
---@param entry LazyPluginsData passed inside `custom_action`
---@param custom_args {foo: string} If needed custom_args could be added in a table
local function demo_custom_function(bufnr, entry, custom_args)
  -- (require telescope inside the function call to not trigger a lazy load when
  -- parsing the config)
  local lp_actions = require("telescope").extensions.lazy_plugins.actions

  local arguments = custom_args.foo -- access values from the custom_args
  local repository_dir = entry.repo_dir -- access values from the selected picker entry
  local message = string.format("%s%s", arguments, repository_dir)
  vim.notify(message)

  -- Use the provided helper builtin functions:
  lp_actions.append_to_telescope_history(bufnr) -- Used by `:Telescope resume` and others.
  lp_actions.close(bufnr)
end
-- etc.
```

Then add it to a map action:

```lua
--- Inside the lazy_plugins config
lazy_plugins = {
  mappings = {
    ["i"] = {
      ["<C-g>d"] = function(prompt_bufnr)
        local args = { foo = "Plugin path from the selected entry.repo_dir: " }
        require("telescope").extensions.lazy_plugins.actions.custom_action(
          prompt_bufnr,
          "repo_dir", -- This is used to validate the entry. Could be any field of LazyPluginsData (name, full_name, filepath, line, repo_url or repo_dir).
          demo_custom_function,
          args
        )
      end,
    },
  },
},
```

</details>

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
```

```lua
--- Custom entry example:
lazy_plugins = {
  custom_entries = {
    {
      name = "custom-entry",
      filepath = vim.fn.stdpath("config") .. "/lua/extra-options/somefile.lua",
      -- Optional:
      line = 42,
      repo_url = "https://www.lua.org/manual/5.2/",
      repo_dir = vim.fn.stdpath("config") .. "/lua/extra-options/",
    },
    -- etc.
  },
},
```

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
