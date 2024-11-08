require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

local opts = { noremap = true, silent = true }

map('n', '<C-h>', ':TmuxNavigateLeft<CR>', opts)
map('n', '<C-j>', ':TmuxNavigateDown<CR>', opts)
map('n', '<C-k>', ':TmuxNavigateUp<CR>', opts)
map('n', '<C-l>', ':TmuxNavigateRight<CR>', opts)
