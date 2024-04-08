-- https://www.reddit.com/r/neovim/comments/zhweuc/comment/izo9br1/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
vim.api.nvim_create_user_command(
  'Redir',
  function(ctx)
    local lines = vim.split(vim.api.nvim_exec(ctx.args, true), '\n', { plain = true })
    vim.cmd('new')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.opt_local.modified = false
  end,
  {
    nargs = '+',
    complete = 'command',
  }
)
