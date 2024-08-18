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
  if not telescope.extensions.lazy_plugins then
    error("unexpected: Telescope Lazy Plugins is not loaded")
    ok_requires = false
  end
  if not ok_requires then
    return
  end

  --- Check config
  local ok_configs = true
  local ok_cfg, config = pcall(require, "telescope._extensions.lazy_plugins.config")
  if not ok_cfg or not config then
    local msg = "Telescope Lazy Plugins configuration couldn't be loaded."
      .. " Maybe a problem in the configuration. Refer to the config examples in the README."
    error(msg)
    ok_configs = false
  else
    ok("Telescope Lazy Plugins configuration found.")
  end
  if not config.options then
    local msg = "Missing options field in configuration."
      .. " Maybe a problem in the configuration. Refer to the config examples in the README."
    error(msg)
    ok_configs = false
  else
    ok("Telescope Lazy Plugins configuration options found.")
  end
  if not ok_configs then
    return
  end

  local opts = config.options --[[@as TelescopeLazyPluginsConfig]]

  --- Check Lazy config path
  if not (vim.uv or vim.loop).fs_stat(opts.lazy_config) then
    error("No Lazy configuration file found. (Set in `lazy_config`)")
  else
    ok(string.format("lazy_config found: `%s`", opts.lazy_config))
  end

  --- Check entries

  local lazy_version = tonumber(require("lazy.core.config").version:sub(1, 2))

  if lazy_version < 11 then
    if not opts.lazy_config then
      local min_plugins = (vim.uv or vim.loop).fs_stat(opts.lazy_config) and 2 or 1
      local lazy_plugins = telescope.extensions.lazy_plugins.finder.finder().results
      if #lazy_plugins < min_plugins then
        error("No plugins configuration files found. Check the `lazy_config` path.")
      else
        warn("No Lazy plugins spec table file found. (Set in `lazy_config`)")
      end
    else
      ok("Path to Lazy plugins spec table file found.")
    end
    return
  end

  if lazy_version >= 11 then
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

    ---@param entry LazyPluginsData
    ---@return boolean
    local function is_custom_entry(entry)
      local custom_entries = vim.tbl_get(config, "options", "custom_entries")
      if custom_entries and #custom_entries > 0 then
        for _, custom in pairs(custom_entries) do
          if entry.name == custom.name and entry.filepath == custom.filepath then
            return true
          end
        end
      end
      return false
    end

    local plugins_without_matches = {}
    for _, plugin in pairs(plugins_collection.results) do
      local full_name = plugin.value.full_name
      if not is_custom_entry(plugin.value) and full_name ~= "folke/lazy.nvim" then
        local filepath = plugin.value.filepath
        -- Only check line 1 plugins since that's the default
        if plugin.value.line == 1 then
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
  end

  --- Check custom user entries
  if config.raw_custom_entries then
    local custom_entries_errors = {}
    local errors_detected = false
    for i, entry in ipairs(config.raw_custom_entries) do
      local msg = ""
      if not entry.name or type(entry.name) ~= "string" or entry.name == "" then
        msg = string.format("- name: '%s'\n", entry.name or "Empty name")
        errors_detected = true
      end
      if not entry.filepath or vim.fn.filereadable(entry.filepath) ~= 1 then
        msg = msg .. string.format("- filepath: '%s'\n", entry.filepath or "Empty filepath")
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
