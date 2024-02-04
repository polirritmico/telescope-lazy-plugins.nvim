local config = require("telescope-lazy-plugin.config")

---@class TelescopeLazyPlugin Picker for Telescope
local M = {}

function M.foo()
  local spec = require("lazy.core.config").options.spec
  for k, v in pairs(spec) do
    if type(v) == "table" then
      if not vim.tbl_contains(v, "import") then
        return
      end
      local module_file = v["import"]
      P(vim.fn.expand(module_file))
      -- local module_file = require(v["import"])
      -- P(module_file)
    end
  end
end

M._picker = require("telescope-lazy-plugin.picker")

M.picker = function()
  M._picker.picker():find()
end

M.setup = config.setup

return M
