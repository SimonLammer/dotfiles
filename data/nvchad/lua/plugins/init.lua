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
    opts = require("configs.treesitter"),
  },
  {
    "williamboman/mason.nvim",
    opts = require("configs.mason"),
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require("configs.lspconfig")
    end,
  },
  vim.tbl_deep_extend("error", require("configs.whichkey"), {
    "folke/which-key.nvim",
  }),
}
