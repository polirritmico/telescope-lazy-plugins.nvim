#!/usr/bin/env -S nvim -l

Remote = false
vim.env.LAZY_STDPATH = ".tests"
local url = "https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"

if Remote then
  load(vim.fn.system("curl -s " .. url))()
else
  local bootstrap = ".tests/bootstrap.lua"
  if not vim.uv.fs_stat(bootstrap) then
    vim.fn.mkdir(vim.fs.dirname(bootstrap), "p")
    vim.fn.system("curl -s " .. url .. " -o " .. bootstrap)
  end
  loadfile(bootstrap)()
end

-- Setup lazy.nvim
require("lazy.minit").busted({
  spec = {
    {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      branch = "0.1.x",
      dependencies = {
        { "nvim-lua/plenary.nvim" },
      },
      opts = {},
    },
  },
})
