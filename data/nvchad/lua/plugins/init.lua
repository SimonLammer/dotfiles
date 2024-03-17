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
  { -- https://github.com/NvChad/NvChad/issues/1246#issuecomment-1817582042
    "folke/which-key.nvim",
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "whichkey")
      require("which-key").setup(opts)
      local present, wk = pcall(require, "which-key")
      if not present then
        return
      end
      wk.register({
        ["<leader>"] = {
          c = {name = "Code"},
          f = {name = "Files"},
          g = {name = "Git"},
          l = {name = "LSP"},
          r = {name = "Relative"},
          t = {name = "Telescope"},
          w = {name = "Whichkey"},
        },
        ["["] = {
          name = "Previous..."
        },
        ["]"] = {
          name = "Next..."
        },
        ["g"] = {
          name = "Goto..."
        },
        ["z"] = {
          name = "Fold"
        },
      })
    end,
    setup = function()
      require("core.utils").load_mappings("whichkey")
    end,
  },
}
