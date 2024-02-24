local config = require("telescope.config").values
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local action_set = require("telescope.actions.set")
local lp_finder = require("telescope._extensions.lazy_plugins.finder")
local lp_config = require("telescope._extensions.lazy_plugins.config")

---Custom picker action to open the file and move the current line at the top.
---@param prompt_bufnr integer Telescope prompt buffer value
local function lp_action(prompt_bufnr)
  -- Append to Telescope history
  action_state
    .get_current_history()
    :append(
      action_state.get_current_line(),
      action_state.get_current_picker(prompt_bufnr)
    )
  -- Open the file in a new buffer
  action_set.select(prompt_bufnr, "default")
  -- Set current line at the top position of the view
  vim.cmd(":normal! zt")
end

---Telescope picker to quickly open plugins configuration files within the Lazy spec.
---@param opts table? Options passed to the Telescope previewer and sorter.
local function lp_picker(opts)
  opts = vim.tbl_deep_extend("force", lp_config.options.picker_opts or {}, opts or {})

  pickers
    .new(opts, {
      finder = lp_finder(),
      preview_title = "Config File Preview",
      previewer = config.grep_previewer(opts),
      prompt_title = "Search Plugins",
      results_title = "Matching Plugins",
      sorter = config.generic_sorter(opts),
      attach_mappings = function()
        actions.select_default:replace(lp_action)
        return true
      end,
    })
    :find()
end

return lp_picker
