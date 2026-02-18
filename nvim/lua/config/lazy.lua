-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
})

-- Auto-update plugins once per calendar day
local last_update_file = vim.fn.stdpath("data") .. "/lazy_last_update" -- ~/.local/share/nvim/lazy_last_update
local function should_update()
  local today = os.date("%Y-%m-%d")
  local last_date = vim.fn.filereadable(last_update_file) == 1 and vim.fn.readfile(last_update_file)[1] or ""
  return today ~= last_date
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if should_update() then
      require("lazy").sync({ wait = false })
      vim.fn.writefile({ os.date("%Y-%m-%d") }, last_update_file)
    end
  end,
})
