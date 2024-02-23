---@class TelescopeLazyPluginsConfig
---@field name_only boolean Match only the `repo_name`, false to match the full `account/repo_name`
---@field show_disabled boolean Also show disabled plugins from the Lazy spec.
---@field lazy_config string? Optional. Path to the file containing the lazy opts and setup() call
---@field lazy_spec_table string? Optional. Path to the file containing the lazy plugin spec table

local M = {}

---@type TelescopeLazyPluginsConfig
local defaults = {
  name_only = true,
  show_disabled = true,
  lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua",
  lazy_spec_table = vim.fn.stdpath("config") .. "/lua/config/lazy.lua",
}

M.options = {}

---@param opts TelescopeLazyPluginsConfig?
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, M.options, opts or {})

  local lazy_cfg = vim.fn.expand(M.options.lazy_config)
  local spec_tbl = vim.fn.expand(M.options.lazy_spec_table)
  M.options.lazy_config = vim.fn.filereadable(lazy_cfg) == 1 and lazy_cfg or nil
  M.options.lazy_spec_table = vim.fn.filereadable(spec_tbl) == 1 and spec_tbl or nil
end

return M
