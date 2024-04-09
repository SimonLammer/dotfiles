return {
  "neovim/nvim-lspconfig",
  config = function()
    require("nvchad.configs.lspconfig").defaults()
    local configs = require("nvchad.configs.lspconfig")

    local on_attach = configs.on_attach
    local on_init = configs.on_init
    local capabilities = configs.capabilities

    local lspconfig = require("lspconfig")
    local servers = { -- `:help lspconfig-all` / https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
      ["clangd"] = {},
      ["pyright"] = {
        filetypes = {"python"},
      },
      ["jdtls"] = {
        cmd = {vim.fn.stdpath "data" .. "/mason/bin/jdtls"},
      },
      --"html",
      --"cssls",
      -- TODO: java lsp
    }

    for lsp, conf in pairs(servers) do
      local s = vim.tbl_deep_extend("error", conf, {
        on_init = on_init,
        on_attach = on_attach,
        capabilities = capabilities,
      })
      lspconfig[lsp].setup(s)
    end
    -- Without the loop, you would have to manually set up each LSP 
    -- 
    -- lspconfig.html.setup {
    --   on_attach = on_attach,
    --   capabilities = capabilities,
    -- }
    --
    -- lspconfig.cssls.setup {
    --   on_attach = on_attach,
    --   capabilities = capabilities,
    -- }
  end,
}

