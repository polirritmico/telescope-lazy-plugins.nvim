local telescope = require("telescope")
local telescope_lazy_plugins = require("telescope-lazy-plugins")

return telescope.register_extension({
  setup = function() end,
  exports = { lazy_plugins = telescope_lazy_plugins.picker },
})
