local function check_health()
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
  local lazy_plugins = telescope.extensions.lazy_plugins.finder.finder().results
  if not opts.lazy_spec_table then
    if #lazy_plugins < min_plugins then
      error("No plugins configuration files found. Check the `lazy_spec_table` path.")
    else
      warn("No Lazy plugins spec table file found. (Set in `lazy_spec_table`)")
    end
  else
    ok("Path to Lazy plugins spec table file found.")
  end

  -- Check custom user entries
  if config.raw_custom_entries then
    local custom_entries_errors = {}
    local errors_detected = false
    for i, entry in ipairs(config.raw_custom_entries) do
      local msg = ""
      if not entry.name or type(entry.name) ~= "string" or entry.name == "" then
        msg = string.format("- name: '%s'\n", entry.name)
        errors_detected = true
      end
      if entry.filepath and vim.fn.filereadable(entry.filepath) ~= 1 then
        msg = msg .. string.format("- filepath: '%s'\n", entry.filepath)
        errors_detected = true
      end
      if entry.repo_dir and vim.fn.isdirectory(entry.repo_dir) ~= 1 then
        msg = msg .. string.format("- repo_dir:\n'%s'\n", entry.repo_dir)
        errors_detected = true
      end

      if msg == "" then
        msg = "- No errors detected\n"
      end
      table.insert(custom_entries_errors, i, msg)
    end

    if errors_detected then
      local msg = "Problems detected in user custom_entries:\n"
      for idx, error_msg in pairs(custom_entries_errors) do
        msg = msg .. string.format("Custom entry number %d:\n%s", idx, error_msg)
      end
      error(msg)
    else
      ok("No problems detected in custom_entries.")
    end
  end
end

return check_health
