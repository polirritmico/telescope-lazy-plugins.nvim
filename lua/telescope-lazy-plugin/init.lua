local config = require("telescope-lazy-plugin.config")

---@class TelescopeLazyPlugin Picker for Telescope
local M = {}

function M.foo()
  vim.notify("Works")
end

M._picker = require("telescope-lazy-plugin.picker")

M.picker = function()
  M._picker.picker():find()
end

M.setup = config.setup

return M
