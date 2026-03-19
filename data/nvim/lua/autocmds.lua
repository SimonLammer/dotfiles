-- Pass yanks to tmux' buffer
if vim.env.TMUX then
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("TmuxYank", { clear = true }),
    callback = function()
      local text = vim.fn.getreg(vim.v.event.regname)
      vim.fn.system({ 'tmux', 'load-buffer', '-'}, text)
    end,
  })
end

