local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This extension requires telescope.nvim")
end

local lp_actions = require("telescope._extensions.lazy_plugins.actions")
local lp_config = require("telescope._extensions.lazy_plugins.config")
local lp_finder = require("telescope._extensions.lazy_plugins.finder")
local lp_picker = require("telescope._extensions.lazy_plugins.picker")

return telescope.register_extension({
  setup = lp_config.setup,
  exports = {
    lazy_plugins = lp_picker,
    actions = lp_actions,
    finder = lp_finder,
  },
})
