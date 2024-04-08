return {
  "hrsh7th/nvim-cmp",
  opts = function()
    local opts = require "nvchad.configs.cmp"
    local cmp = require "cmp"
    opts.mapping["<C-S-k>"] = cmp.mapping.select_prev_item {}
    opts.mapping["<C-S-j>"] = cmp.mapping.select_next_item {}
    for _, cmd in ipairs({"<CR>", "<Tab>"}) do
      opts.mapping[cmd] = function()
        cmp.mapping.close {}
        Feedkeys(cmd, "n")
      end
    end
    opts.mapping["<C-y>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }
    --opts.experimental["ghost_text"] = true
    table.insert(opts.sources, { name = "crates" })
    return opts
  end,
}
