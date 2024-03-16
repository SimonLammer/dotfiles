return {
  {
    "stevearc/conform.nvim",
    config = function()
      require "configs.conform"
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      git = { enable = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = require("configs.nvim-treesitter"),
--  config = function()
--    require "nvchad.configs.nvim-treesitter"
  },

--{
--  "neovim/nvim-lspconfig",
--  config = function()
--    require("nvchad.configs.lspconfig")
--    require("configs.lspconfig")
--  end,
--},
}
