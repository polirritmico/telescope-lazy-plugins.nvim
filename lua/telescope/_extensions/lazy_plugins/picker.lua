local config = require("telescope.config").values
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local lp_finder = require("telescope._extensions.lazy_plugins.finder")
local lp_config = require("telescope._extensions.lazy_plugins.config")
local lp_actions = require("telescope._extensions.lazy_plugins.actions")

---Telescope picker to quickly open plugins configuration files within the Lazy spec.
---@param opts table? Options passed to the Telescope previewer and sorter.
local function lp_picker(opts)
  opts = vim.tbl_deep_extend("force", lp_config.options or {}, opts or {})

  local function attach_mappings(_, map)
    actions.select_default:replace(lp_actions.open)
    for mode, keys in pairs(opts.mappings) do
      for lhs, action in pairs(keys) do
        if lhs and lhs ~= "" and action then
          map(mode, lhs, action)
        end
      end
    end
    return true
  end

  pickers
    .new(opts.picker_opts, {
      actions = lp_actions,
      attach_mappings = attach_mappings,
      finder = lp_finder.finder(opts),
      preview_title = "Config File Preview",
      previewer = config.grep_previewer(opts),
      prompt_title = "Search Plugins",
      results_title = "Matching Plugins",
      sorter = config.generic_sorter(opts),
    })
    :find()
end

return lp_picker
