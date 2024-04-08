require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })

map("n", "<leader>fm", function()
  require("conform").format()
end, { desc = "File Format with conform" })

map("i", "kj", "<ESC>", { desc = "Escape insert mode" })

-- Use alt + hjkl to resize windows
local window_resize_offset = 2
map("n", "<M-j>", function()
  vim.api.nvim_win_set_height(0, vim.api.nvim_win_get_height(0) - window_resize_offset)
end)
map("n", "<M-k>", function()
  vim.api.nvim_win_set_height(0, vim.api.nvim_win_get_height(0) + window_resize_offset)
end)
map("n", "<M-h>", function()
  vim.api.nvim_win_set_width(0, vim.api.nvim_win_get_width(0) - window_resize_offset)
end)
map("n", "<M-l>", function()
  vim.api.nvim_win_set_width(0, vim.api.nvim_win_get_width(0) + window_resize_offset)
end)

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

