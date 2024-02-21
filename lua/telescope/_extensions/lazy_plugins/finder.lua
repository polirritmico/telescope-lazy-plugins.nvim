local finders = require("telescope.finders")
local lp_config = require("telescope._extensions.lazy_plugins.config")

---Stores the relevant Lazy plugin spec data to use the picker.
---@class LazyPluginData
---@field name string Plugin name
---@field repo_name string Full name of the plugin repository
---@field filepath string Full file path to the plugin lua configuration
---@field line integer Line number of the plugin definition in the lua file

---Finds the line number matching the plugin repository name within the plugin file
---@private
---@param repo_name string Repository name (username/plugin)
---@param filepath string Full file path
---@return integer -- Matching line number
local function line_number_search(repo_name, filepath)
  local current_line = 1
  for line_str in io.lines(filepath) do
    if string.find(line_str, repo_name, 1, true) then
      return current_line
    end
    current_line = current_line + 1
  end
  return 1
end

---Get the lazy_plugin module full filepath from the runtimepath
---@param lazy_plugin table Plugin spec to insert into the `tbl`
---@return string
local function get_module_filepath(lazy_plugin)
  local rtp = vim.opt.rtp:get()
  assert(lazy_plugin._.module ~= nil, "Missing module on lazy spec: " .. lazy_plugin.name)
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

---Parse the `lazy_plugin` spec and insert it into the `tbl` collection.
---@private
---@param tbl table<LazyPluginData> Target table with the plugins collection
---@param lazy_plugin table Plugin spec to insert into the `tbl`
---@param spec_level integer? For plugin configs split into multiple files.
local function add_plugin(tbl, lazy_plugin, spec_level)
  spec_level = spec_level or 1
  local repo_name = lazy_plugin[1]
  local entry_name = lp_config.options.name_only and lazy_plugin.name or repo_name
  local filepath = get_module_filepath(lazy_plugin)
  local line = line_number_search(repo_name, filepath)

  local has_duplicates = false
  for _, check_plugin in pairs(tbl) do
    if
      repo_name == check_plugin.repo_name
      and filepath == check_plugin.filepath
      and line == check_plugin.line
    then
      has_duplicates = true
      spec_level = spec_level - 1
      break
    end
  end

  if not has_duplicates then
    if spec_level > 1 then
      entry_name = string.format("%s(%d)", entry_name, spec_level)
    end
    if lazy_plugin.enabled == false then
      entry_name = entry_name .. " (disabled)"
    end

    ---@type LazyPluginData
    local plugin = {
      name = entry_name,
      repo_name = repo_name,
      filepath = filepath,
      line = line,
    }
    table.insert(tbl, plugin)
  end

  if lazy_plugin._.super then
    add_plugin(tbl, lazy_plugin._.super, spec_level + 1)
  end
end

---Get the Lazy plugin data from the Lazy specification. For each plugin,
---obtains the plugin name, repository name (<username/plugin>), full file path
---of the Lua file containing the plugin config, and the line number where the
---repository name is found.
---@private
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
      add_plugin(plugins_collection, plugin)
    end
  end

  if vim.fn.filereadable(vim.fn.expand(lp_config.options.lazy_config)) == 1 then
    table.insert(plugins_collection, {
      name = lp_config.options.name_only and "lazy.nvim" or "folke/lazy.nvim",
      repo_name = "folke/lazy.nvim",
      filepath = lp_config.options.lazy_config,
      line = 1,
    })
  end

  -- table.sort(plugins_collection, function(a, b) return a.name < b.name end)
  return plugins_collection
end

---Finder to use with the Telescope API. Get the plugin data for each plugin
---registered on the Lazy spec.
local function lazy_plugins_finder()
  local plugins = {
    results = get_plugins_data(),
    ---@param entry LazyPluginData
    entry_maker = function(entry)
      return {
        value = entry,
        display = entry.name,
        ordinal = entry.name,
        path = entry.filepath,
        lnum = entry.line,
      }
    end,
  }
  return finders.new_table(plugins)
end

return lazy_plugins_finder
