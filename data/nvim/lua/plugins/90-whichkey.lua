return { -- https://github.com/NvChad/NvChad/issues/1246#issuecomment-1817582042
  "folke/which-key.nvim",
  config = function(_, opts)
    -- TODO: adjust mappings acc. https://github.com/folke/which-key.nvim?tab=readme-ov-file#%EF%B8%8F-mappings
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
}

