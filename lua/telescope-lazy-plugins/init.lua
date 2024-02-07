local config = require("telescope-lazy-plugins.config")

---@class TelescopeLazyPlugin Picker for Telescope
local M = {}

M._picker = require("telescope-lazy-plugins.picker")

M.picker = function()
  M._picker.picker():find()
end

M.setup = config.setup

return M
