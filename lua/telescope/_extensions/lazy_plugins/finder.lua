local finders = require("telescope.finders")
local lp_config = require("telescope._extensions.lazy_plugins.config")
local lp_make_entry = require("telescope._extensions.lazy_plugins.make_entry")

---Stores the relevant Lazy plugin spec data to use the picker.
---@class LazyPluginData
---@field name string Plugin name
---@field repo_name string Full name of the plugin repository
---@field filepath string Full file path to the plugin lua configuration
---@field line integer Line number of the plugin definition in the lua file
---@field repo_url integer Url to the repo

---Finds the line number matching the plugin repository name within the plugin file
---@param repo_name string Repository name (username/plugin)
---@param filepath string Full file path
---@return integer -- Matching line number
local function line_number_search(repo_name, filepath)
  local current_line = 1
  local search_str = string.format([["%s"]], repo_name)
  for line_str in io.lines(filepath) do
    if string.find(line_str, search_str, 1, true) then
      return current_line
    end
    current_line = current_line + 1
  end
  return 1
end

---Get the lazy_plugin module full filepath from the runtimepath
---@param lazy_plugin table Plugin spec to obtain the module full filepath
---@return string?
local function get_module_filepath(lazy_plugin)
  local rtp = vim.opt.rtp:get()

  if not lazy_plugin._.module then
    if lp_config.options.lazy_spec_table then
      return lp_config.options.lazy_spec_table
    else
      error("Missing module in the lazy spec: " .. lazy_plugin.name, vim.log.levels.WARN)
      return
    end
  end

  local mod = lazy_plugin._.module:gsub("%.", "/")
  for _, rtp_path in ipairs(rtp) do
    local check_path = string.format("%s/lua/%s", rtp_path, mod)
    if vim.fn.filereadable(check_path .. ".lua") == 1 then
      return check_path .. ".lua"
    elseif vim.fn.filereadable(check_path .. "/init.lua") == 1 then
      return check_path .. "/init.lua"
    end
  end
  error("Module file not found on the rtp: `" .. lazy_plugin.name .. "`", 2)
end

---Create all the LazyPluginData configs of the plugin from the lazy spec. The
---function recursively extract the `plugin._.super` field into one table.
---@param plugin table Plugin data from the lazy spec
---@return table<LazyPluginData> collected_configs Contains all the plugin data from the lazy spec
local function collect_config_files(plugin)
  local collected_configs = {}
  if plugin._.super then
    local inner_configs = collect_config_files(plugin._.super)
    for _, inner_plugin in pairs(inner_configs) do
      table.insert(collected_configs, inner_plugin)
    end
  end

  -- TODO: better handle of dir only and url only spec
  local repo_name = type(plugin[1]) == "string" and plugin[1] or plugin.url
  if not repo_name then
    return collected_configs
  end
  local filepath = get_module_filepath(plugin)
  if not filepath then
    return collected_configs
  end
  local repo_url = plugin.url and plugin.url:gsub("%.git$", "")
    or "https://github.com/" .. repo_name

  local current_plugin = {
    repo_name = repo_name,
    repo_url = repo_url,
    name = lp_config.options.name_only and plugin.name or repo_name,
    filepath = filepath,
    file = filepath:match(".*/(.*/.*)%.%w+"),
    line = line_number_search(repo_name, filepath),
    disabled = false,
  }
  table.insert(collected_configs, current_plugin)

  return collected_configs
end

---Parse the `lazy_plugin` spec and insert it into the `tbl` collection.
---@param tbl table<LazyPluginData> Target table with the plugins collection
---@param lazy_plugin table Plugin spec to insert into the `tbl`
---@param disabled? boolean Optional. If disabled is true adds ' (disabled)' to the plugin name
local function add_plugin(tbl, lazy_plugin, disabled)
  disabled = disabled or false
  local configs = collect_config_files(lazy_plugin)
  if #configs == 0 then
    local msg = "No configuration files found for " .. lazy_plugin.name
    vim.notify(msg, vim.log.levels.WARN)
    return
  end

  configs[1].disabled = disabled
  table.insert(tbl, configs[1])

  local duplicates_counter = 1
  for _, plugin_cfg in pairs(configs) do
    local duplicated = false
    for _, plugin_in_tbl in pairs(tbl) do
      if
        plugin_cfg.repo_name == plugin_in_tbl.repo_name
        and plugin_cfg.filepath == plugin_in_tbl.filepath
        and plugin_cfg.line == plugin_in_tbl.line
      then
        duplicated = true
        break
      end
    end
    if not duplicated then
      duplicates_counter = duplicates_counter + 1
      plugin_cfg.name = string.format("%s(%d)", plugin_cfg.name, duplicates_counter)
      plugin_cfg.disabled = disabled
      table.insert(tbl, plugin_cfg)
    end
  end
end

---Get the Lazy plugin data from the Lazy specification. For each plugin,
---obtains the plugin name, repository name (<username/plugin>), full file path
---of the Lua file containing the plugin config, and the line number where the
---repository name is found.
---@return table<LazyPluginData>
local function get_plugins_data()
  local plugins_collection = {}
  local lazy_spec = require("lazy.core.config").spec

  for _, plugin in pairs(lazy_spec.plugins) do
    if plugin.name ~= "lazy.nvim" and plugin.name ~= "LazyVim" then
      add_plugin(plugins_collection, plugin)
    end
  end
  if lp_config.options.show_disabled then
    for _, plugin in pairs(lazy_spec.disabled) do
      add_plugin(plugins_collection, plugin, true)
    end
  end

  if lp_config.options.lazy_config then
    table.insert(plugins_collection, {
      name = lp_config.options.name_only and "lazy.nvim" or "folke/lazy.nvim",
      repo_name = "folke/lazy.nvim",
      repo_url = "https://github.com/folke/lazy.nvim",
      filepath = lp_config.options.lazy_config,
      file = lp_config.options.lazy_config:match("[^/]+$"),
      line = 1,
      disabled = false,
    })
  end

  -- table.sort(plugins_collection, function(a, b) return a.name < b.name end)
  return plugins_collection
end

---Finder to use with the Telescope API. Get the plugin data for each plugin
---registered on the Lazy spec.
local function lazy_plugins_finder(opts)
  opts = vim.tbl_deep_extend("force", lp_config.options or {}, opts or {})

  return finders.new_table({
    results = get_plugins_data(),
    entry_maker = lp_make_entry(opts),
  })
end

return lazy_plugins_finder
