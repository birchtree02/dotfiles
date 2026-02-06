require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- local opts = { noremap = true, silent = true }

-- map('n', '<C-h>', ':TmuxNavigateLeft<CR>', opts)
-- map('n', '<C-j>', ':TmuxNavigateDown<CR>', opts)
-- map('n', '<C-k>', ':TmuxNavigateUp<CR>', opts)
-- map('n', '<C-l>', ':TmuxNavigateRight<CR>', opts)
--
--
local function smart_move(direction, tmux_cmd)
  local curwin = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. direction)
  if curwin == vim.api.nvim_get_current_win() then
    vim.fn.system('tmux select-pane ' .. tmux_cmd)
  end
end

vim.keymap.set('n', '<C-h>', function() smart_move('h', '-L') end, {silent = true})
vim.keymap.set('n', '<C-j>', function() smart_move('j', '-D') end, {silent = true})
vim.keymap.set('n', '<C-k>', function() smart_move('k', '-U') end, {silent = true})
vim.keymap.set('n', '<C-l>', function() smart_move('l', '-R') end, {silent = true})

map("n", "<leader>gb", ":Gitsigns blame<CR>")
map("n", "<leader>gbl", ":Gitsigns blame_line<CR>")
