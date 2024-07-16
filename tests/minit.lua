#!/usr/bin/env -S nvim -l

vim.env.LAZY_STDPATH = ".tests"
vim.env.LAZY_PATH = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- stylua: ignore
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

vim.opt.rtp:prepend(".")

-- Setup lazy.nvim
require("lazy.minit").setup({
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
