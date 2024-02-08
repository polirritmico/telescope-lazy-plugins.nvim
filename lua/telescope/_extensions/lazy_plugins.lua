local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This extension requires telescope.nvim")
end

local lazy_plugins_picker = require("telescope._extensions.lazy_plugins.picker")

return telescope.register_extension({
  exports = { lazy_plugins = lazy_plugins_picker },
})
