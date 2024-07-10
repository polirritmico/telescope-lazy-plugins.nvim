local function check_health()
  local health = vim.health or require("health")
  ---@diagnostic disable: deprecated
  local ok = health.ok or health.report_ok
  local warn = health.warn or health.report_warn
  local error = health.error or health.report_error

  --- Check requires
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

  --- Check Lazy config path
  if not (vim.uv or vim.loop).fs_stat(opts.lazy_config) then
    error("No Lazy configuration file found. (Set in `lazy_config`)")
  else
    ok("Lazy configuration file was found.")
  end

  --- Check plugins imports and search lines
  local finder = telescope.extensions.lazy_plugins.finder
  local collection_ok, plugins_collection = pcall(finder.finder)
  if not collection_ok then
    warn("Problems detected importing plugin configurations. Maybe missing entries.")
  else
    ok("No problems importing plugins config specs.")
  end
  local min_plugins = 4 -- at least: lazy, telescope, plenary and telescope-lazy-plugins
  if #plugins_collection.results < min_plugins then
    error("Missing plugins (at least 4). Check configuration.")
  end

  local plugins_without_matches = {}
  for _, plugin in pairs(plugins_collection.results) do
    local full_name = plugin.value.full_name
    if full_name ~= "folke/lazy.nvim" then
      local filepath = plugin.value.filepath
      if plugin.value.line == 1 then -- since 1 is the default value only check those plugins
        local _, match = finder.line_number_search(full_name, filepath)
        if not match then
          table.insert(plugins_without_matches, { name = full_name, path = filepath })
        end
      end
    end
  end
  if #plugins_without_matches > 0 then
    local msg = "Problems detected searching plugin(s) in the config files:\n"
    for _, plugin in pairs(plugins_without_matches) do
      msg = msg .. "- name: '" .. plugin.name .. "'\n"
      msg = msg .. "  file: '" .. plugin.path .. "'\n"
    end
    error(msg)
  else
    ok("Found all imported plugin configurations in the module files.")
  end

  --- Check custom user entries
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
