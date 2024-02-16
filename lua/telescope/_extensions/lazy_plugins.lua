local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This extension requires telescope.nvim")
end

local lp_picker = require("telescope._extensions.lazy_plugins.picker")
local lp_config = require("telescope._extensions.lazy_plugins.config")

return telescope.register_extension({
  setup = lp_config.setup,
  exports = { lazy_plugins = lp_picker },
})
