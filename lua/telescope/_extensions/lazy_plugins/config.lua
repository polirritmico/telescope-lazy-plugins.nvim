---@class TelescopeLazyPluginsConfig
---@field name_only boolean Match only the `repo_name`, false to match the full `account/repo_name`
---@field show_disabled boolean Also show disabled plugins from the Lazy spec.
---@field lazy_config string? Optional. Path to the file containing the lazy opts and setup() call

local M = {}

---@type TelescopeLazyPluginsConfig
local defaults = {
  name_only = true,
  show_disabled = true,
  lazy_config = vim.fn.stdpath("config") .. "/lua/config/lazy.lua",
}

M.options = {}

---@param opts TelescopeLazyPluginsConfig?
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, M.options, opts or {})
end

return M
