local M = {}

---@class TelescopeLazyPluginsHealth
function M.health()
  local health = vim.health or require("health")
  local ok = health.ok or health.report_ok
  local warn = health.warn or health.report_warn
  local error = health.error or health.report_error

  local ok_requires = true
  local telescope_ok, telescope = pcall(require, "telescope")
  if not telescope_ok then
    error("unexpected: Telescope configuration couldn't be loaded.")
    ok_requires = false
  end
  if not pcall(require, "lazy") then
    error("unexpected: Can't access Lazy config spec.")
    ok_requires = false
  end
  local ok_cfg, config = pcall(require, "telescope._extensions.lazy_plugins.config")
  if not ok_cfg or not config then
    error("unexpected: Telescope Lazy Plugins configuration couldn't be loaded.")
    ok_requires = false
  end
  if not ok_requires then
    return
  end

  local opts = config.options ---@type TelescopeLazyPluginsConfig
  local min_plugins = 1

  -- Check Lazy config path
  if not opts.lazy_config then
    warn("No Lazy configuration file found. (Set in `lazy_config`)")
  else
    ok("Lazy configuration file was found.")
    min_plugins = 2 -- with this option OK, lazy.nvim should be in the results
  end

  -- Check plugins spec
  local lazy_plugins = telescope.extensions.lazy_plugins.finder().results
  if not opts.lazy_spec_table then
    if #lazy_plugins < min_plugins then
      error("No plugins configuration files found. Check the `lazy_spec_table` path.")
    else
      warn("No Lazy plugins spec table file found.")
    end
  else
    ok("Path to Lazy plugins spec table file found.")
  end
end

return M.health
