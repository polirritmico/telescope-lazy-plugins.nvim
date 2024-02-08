---Telescope picker to quickly open plugin configuration files within the Lazy spec.
---@class TelescopeLazyPlugins
---@field picker fun(opts: table?)
local M = {}

M.telescope_picker = require("telescope-lazy-plugins.picker")

function M.picker(opts)
  M.telescope_picker.picker(opts):find()
end

function M.setup()
  local ok, telescope = pcall(require, "telescope")
  if not ok then
    error("Missing nvim-telescope/telescope.nvim")
  end
  telescope.load_extension("telescope-lazy-plugins")
end

return M
