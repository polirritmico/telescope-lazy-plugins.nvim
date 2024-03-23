local lp_actions = require("telescope._extensions.lazy_plugins.actions")
local lp_highlights = require("telescope._extensions.lazy_plugins.highlights")

---@class TelescopeLazyPluginsConfig
---@field lazy_config string? Optional. Path to the file containing the lazy opts and setup() call
---@field lazy_spec_table string? Optional. Path to the file containing the lazy plugin spec table
---@field mappings table Keymaps attached to the picker. See `:h telescope.mappings`
---@field name_only boolean Match only the `repo_name`, false to match the full `account/repo_name`
---@field picker_opts table Layout options passed into Telescope. Check `:h telescope.layout`
---@field show_disabled boolean Also show disabled plugins from the Lazy spec

local M = {}

---@type TelescopeLazyPluginsConfig
local defaults = {
  name_only = true,
  show_disabled = true,
  lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua",
  lazy_spec_table = vim.fn.stdpath("config") .. "/lua/config/lazy.lua",
  mappings = {
    ["i"] = {
      ["<C-g>"] = lp_actions.open_repo_url,
      ["<C-r>"] = lp_actions.open_repo_dir,
      -- HACK: Add a dummy function to avoid closing the picker on a mouse click
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

M.options = M.options or {}

---@param opts TelescopeLazyPluginsConfig?
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", defaults, M.options, opts or {})

  local lazy_cfg = vim.fn.expand(M.options.lazy_config)
  local spec_tbl = vim.fn.expand(M.options.lazy_spec_table)
  M.options.lazy_config = vim.fn.filereadable(lazy_cfg) == 1 and lazy_cfg or nil
  M.options.lazy_spec_table = vim.fn.filereadable(spec_tbl) == 1 and spec_tbl or nil

  lp_highlights.setup()
end

return M
