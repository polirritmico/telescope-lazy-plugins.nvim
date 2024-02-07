local M = {}

---@class Config
---@field from_lazy_only boolean
M.defaults = {
  from_lazy_only = true,
}

---@type Config
M.options = {}

---@param options Config?
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options or {})
end

return M
