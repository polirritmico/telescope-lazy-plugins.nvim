local M = {}

local links = {
  [""] = nil,
  Enabled = "Function",
  Disabled = "Delimiter",
  File = "Comment",
}

function M.setup()
  for k, v in pairs(links) do
    vim.api.nvim_set_hl(0, "TelescopeLazyPlugins" .. k, { link = v, default = true })
  end
end

return M
