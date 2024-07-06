#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"
-- vim.env.LAZY_PATH = vim.fs.normalize("~/.local/share/nvim/lazy/lazy.nvim")

vim.opt.rtp:prepend(".")

-- stylua: ignore
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

-- Setup lazy.nvim
require("lazy.minit").busted({
  spec = {
    "nvim-telescope/telescope.nvim",
  },
})
