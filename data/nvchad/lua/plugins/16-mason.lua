return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "clangd",
      "lua-language-server",
      "pyright",
      --"html-lsp",
      --"prettier",
      --"stylua",
      --"gopls"
      -- TODO: java lsp
    },
  },
}
