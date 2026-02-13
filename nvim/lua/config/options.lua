vim.g.mapleader = " "
vim.g.markdown_recommended_style = 0
vim.g.autoformat = true

local opt = vim.opt

opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
opt.autowrite = true -- Auto write on change buffer
opt.completeopt = "menu,menuone,noselect"
opt.number = true -- shows line numbers
opt.relativenumber = true -- shows relative line numbers
opt.tabstop = 2 -- number of spaces tabs count for
opt.shiftwidth = 2 -- size of an indent
opt.expandtab = true -- Use spaces instead of tabs
opt.confirm = true -- Confirm saving changes
opt.cursorline = true -- Enable highlighting of the current line
opt.ignorecase = true -- Ignore case
opt.mouse = "a" -- Enable mouse mode
opt.undofile = true -- saves undo history when file saved
opt.undolevels = 10000 -- how many changes are remembered
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap


