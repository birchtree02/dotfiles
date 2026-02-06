require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
vim.opt.relativenumber = true

-- Disable undo file if path is too long
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    local undofile = vim.fn.undofile(vim.fn.expand("%"))
    if #undofile > 255 then
      vim.bo.undofile = false
    end
  end,
})
