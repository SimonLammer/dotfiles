-- required from NvChad/lua/nvconfig.lua
local M = {}

-- Terminal colors: https://github.com/gawin/bash-colors-256
-- /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/gawin/bash-colors-256/master/colors)"

M.ui = {
  theme = "gruvbox",
  hl_override = {
    CursorLine = {
      bg = "#202020",
    },
    ColorColumn = {
      bg = "#202020",
    },
  },
}

function Feedkeys(command, mode)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(command, true, true, true),
    mode,
    false
  )
end

vim.cmd("set termguicolors")

vim.opt.background = "dark"
vim.opt.showbreak = "↪ "

vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"
--vim.opt.colorcolumn = [80]
vim.api.nvim_set_option_value("colorcolumn", "80,120", {})

vim.opt.expandtab = true -- Replace tabs with spaces
vim.opt.shiftwidth = 2   -- Width for autoindents
vim.opt.softtabstop = 2  -- See multiple spaces as tabstops so <BS> is sane
vim.opt.tabstop = 2      -- Tabs display as 2 spaces



return M
