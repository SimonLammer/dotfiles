local M = {}

M.ui = {
  theme = "gruvbox",
}

function Feedkeys(command, mode)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(command, true, true, true),
    mode,
    false
  )
end

return M
