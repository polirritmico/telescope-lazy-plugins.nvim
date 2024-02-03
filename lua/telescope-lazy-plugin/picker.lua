local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config").values

---@class TelescopeLazyPicker Telescope picker to select plugins from the Lazy spec
local TelescopeLazyPicker = {}

TelescopeLazyPicker.finder = function()
  local plugins = {
    results = {
      {
        "persisted",
        "/home/eduardo/.config/nvim/lua/polirritmico/plugins/develop/persisted.lua",
        3,
      },
      {
        "monokai-nightasty",
        "/home/eduardo/.config/nvim/lua/polirritmico/plugins/ui/monokai-nightasty.lua",
        4,
      },
      {
        "telescope",
        "/home/eduardo/.config/nvim/lua/polirritmico/plugins/core/telescope.lua",
        3,
      },
    },
    entry_maker = function(entry)
      return {
        value = entry,
        display = entry[1],
        ordinal = entry[1],
        path = entry[2],
        lnum = entry[3],
      }
    end,
  }
  return finders.new_table(plugins)
end

TelescopeLazyPicker.picker = function(opts)
  opts = opts or {}
  -- local lazy_full_spec = require("lazy.core.config").plugins

  return pickers.new(opts, {
    prompt_title = "Plugins in the Lazy spec",
    finder = TelescopeLazyPicker.finder(),
    sorter = config.file_sorter(opts),
    previewer = config.file_previewer(opts),
  })

  -- return plugins
end

return TelescopeLazyPicker
