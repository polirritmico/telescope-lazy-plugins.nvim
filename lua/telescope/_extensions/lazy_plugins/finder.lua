local finders = require("telescope.finders")

---Stores the relevant Lazy plugin spec data to use the picker.
---@class LazyPluginData
---@field name string Plugin name
---@field repo_name string Full name of the plugin repository
---@field filepath string Full file path to the plugin lua configuration
---@field line integer Line number of the plugin definition in the lua file
local LazyPluginSpecData = {}

---Finds the line number matching the plugin repository name within the plugin file
---@private
---@param repo_name string Repository name (username/plugin)
---@param filepath string Full file path
---@return integer -- Matching line number
local function search_and_set_the_line_number(repo_name, filepath)
  local current_line = 1
  for line_str in io.lines(filepath) do
    if string.find(line_str, repo_name, 1, true) then
      return current_line
    end
    current_line = current_line + 1
  end
  return 1
end

---Parse the `lazy_plugin` spec and insert it into the `tbl` collection.
---@private
---@param tbl table<LazyPluginData> Target table with the plugins collection
---@param lazy_plugin table Plugin spec to insert into the `tbl`
---@param recursion_level integer? For plugin configs split into multiple files.
local function add_plugin(tbl, lazy_plugin, recursion_level)
  recursion_level = recursion_level == nil and 1 or recursion_level
  local config_path = vim.fn.stdpath("config")
  local module_file = lazy_plugin._.module:gsub("%.", "/")
  -- TODO: Improve this approach to ensure compatibility with other setups, like LazyVim
  local filepath = string.format("%s/lua/%s.lua", config_path, module_file)

  local entry_name = lazy_plugin.name
  if lazy_plugin._.super ~= nil then
    add_plugin(tbl, lazy_plugin._.super, recursion_level + 1)
    entry_name = string.format("%s(%d)", entry_name, recursion_level + 1)
  end

  ---@type LazyPluginData
  local plugin = {
    name = entry_name,
    repo_name = lazy_plugin[1],
    filepath = filepath,
    line = search_and_set_the_line_number(lazy_plugin[1], filepath),
  }
  table.insert(tbl, plugin)
end

---Get the Lazy plugin data from the Lazy specification. For each plugin,
---obtains the plugin name, repository name (<username/plugin>), full file path
---of the Lua file containing the plugin config, and the line number where the
---repository name is found.
---@private
---@return table<LazyPluginData>
local function get_plugins_data()
  local plugins_collection = {}
  local lazy_plugins = require("lazy").plugins()

  for _, lazy_plugin in pairs(lazy_plugins) do
    if lazy_plugin.name ~= "lazy.nvim" then
      add_plugin(plugins_collection, lazy_plugin)
    end
  end
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
