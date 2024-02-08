local config = require("telescope.config").values
local pickers = require("telescope.pickers")
local lp_finder = require("telescope._extensions.lazy_plugins.finder")

---Telescope picker to quickly open plugins configuration files within the Lazy spec.
---@param opts table? Options passed to the Telescope previewer and sorter.
local function lp_picker(opts)
  opts = opts or {}
  pickers
    .new(opts, {
      finder = lp_finder(),
      previewer = config.file_previewer(opts),
      prompt_title = "Search Plugins",
      preview_title = "Config File Preview",
      results_title = "Matching Plugins",
      sorter = config.file_sorter(opts),
    })
    :find()
end

return lp_picker
