local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config").values

---@class TelescopeLazyPicker Telescope picker to select plugins from the Lazy spec
local TelescopeLazyPicker = {}

-- TODO: plugin spec data: name, git name, filepath, linenumber
function TelescopeLazyPicker._get_plugins_data()
  local spec_files = {}
  local lazy_plugins = require("lazy").plugins()
  local config_path = vim.fn.stdpath("config")

  for _, plugin in pairs(lazy_plugins) do
    local name = plugin.name
    local repo_name = plugin[1]
    if name ~= "lazy.nvim" then
      local plugin_module = ""
      if plugin._.super ~= nil then
        plugin_module = plugin._.super._.module:gsub("%.", "/")
      else
        plugin_module = plugin._.module:gsub("%.", "/")
      end
      local module_path = string.format("%s/lua/%s.lua", config_path, plugin_module)
      table.insert(spec_files, { name, repo_name, module_path, 0 })
    end
  end
  return spec_files
end

function TelescopeLazyPicker.index_plugins_data(data)
  local function find_line_number(search_string, filename)
    local line_number = 1
    for line in io.lines(filename) do
      if string.find(line, search_string, 1, true) then
        return line_number
      end
      line_number = line_number + 1
    end
    return 1
  end

  for _, plugin in pairs(data) do
    if type(plugin) ~= "number" then
      local name = plugin[2]
      local path = plugin[3]
      plugin[4] = find_line_number(name, path)
    end
  end
  return data
end

function TelescopeLazyPicker.finder()
  local plugins_data = TelescopeLazyPicker._get_plugins_data()
  local plugins = {
    results = TelescopeLazyPicker.index_plugins_data(plugins_data),
    entry_maker = function(entry)
      return {
        value = entry,
        display = entry[1],
        ordinal = entry[1],
        path = entry[3],
        lnum = entry[4],
      }
    end,
  }
  return finders.new_table(plugins)
end

function TelescopeLazyPicker.picker(opts)
  opts = opts or {}

  return pickers.new(opts, {
    prompt_title = "Plugins in the Lazy spec",
    finder = TelescopeLazyPicker.finder(),
    sorter = config.file_sorter(opts),
    previewer = config.file_previewer(opts),
  })

  -- return plugins
end

return TelescopeLazyPicker
