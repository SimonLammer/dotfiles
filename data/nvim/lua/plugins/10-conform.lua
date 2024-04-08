return {
  "stevearc/conform.nvim",
  config = require("conform").setup({
    lsp_fallback = true,

    formatters_by_ft = {
      lua = { "stylua" },
    },
  }),
}
