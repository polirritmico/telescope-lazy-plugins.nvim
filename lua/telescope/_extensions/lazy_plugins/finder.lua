local finders = require("telescope.finders")

---Stores the relevant Lazy plugin spec data to use the picker.
---@class LazyPluginData
---@field name string Plugin name
---@field repo_name string Full name of the plugin repository
---@field filepath string Full file path to the plugin lua configuration
---@field line integer Line number of the plugin definition in the lua file
local LazyPluginSpecData = {}

---Finds the line number matching the plugin repository name within the plugin
---file and updates the `line` field of the provided `plugin` object accordingly.
---@param plugin LazyPluginData
local function _search_and_set_the_line_number(plugin)
  local line = 1
  for line_str in io.lines(plugin.filepath) do
    if string.find(line_str, plugin.repo_name, 1, true) then
      plugin.line = line
      return
    end
    line = line + 1
  end
end

---Get the Lazy plugin data from the Lazy specification. For each plugin,
---obtains the plugin name, repository name (<username/plugin>), full file path
---of the Lua file containing the plugin config, and the line number where the
---repository name is found.
---@return table<LazyPluginData>
local function _get_plugins_data()
  local plugins_collection = {}
  local lazy_plugins = require("lazy").plugins()
  local config_path = vim.fn.stdpath("config")

  for _, lazy_plugin in pairs(lazy_plugins) do
    if lazy_plugin.name ~= "lazy.nvim" then
      local module_file = lazy_plugin._.super ~= nil and lazy_plugin._.super._.module
        or lazy_plugin._.module
      module_file = module_file:gsub("%.", "/")

      ---@type LazyPluginData
      local plugin = {
        name = lazy_plugin.name,
        repo_name = lazy_plugin[1],
        filepath = string.format("%s/lua/%s.lua", config_path, module_file),
        line = 0,
      }
      _search_and_set_the_line_number(plugin)
      table.insert(plugins_collection, plugin)
    end
  end
  return plugins_collection
end

---Finder to use with the Telescope API. Get the plugin data for each plugin
---registered on the Lazy spec.
local function lazy_plungins_finder()
  local plugins = {
    results = _get_plugins_data(),
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

return lazy_plungins_finder
