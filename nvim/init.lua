vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.g.maplocalleader = ";"
vim.o.timeoutlen = 1500

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)
require("java").setup()

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

require "configs.markdown"
require "configs.molten"
require "plugins.tmux"
require "configs.ide"

vim.g.python3_host_prog=vim.fn.expand("~/.virtualenvs/neovim/bin/python3")

local enable_providers = {
      "python3_provider",
    }
for _, plugin in pairs(enable_providers) do
    vim.g["loaded_" .. plugin] = nil
    vim.cmd("runtime " .. plugin)
end
