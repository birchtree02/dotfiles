vim.keymap.set("n", "<leader>o", function ()
  vim.fn.jobstart({"tatum", "serve", "--open", vim.fn.expand('%')}, { noremap = true, silent = true })
end)
-- vim.keymap.set("n", "<leader>mt", ":Markview toggle<CR>",
  -- { noremap = true, silent = true } )
