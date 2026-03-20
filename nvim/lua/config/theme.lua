vim.o.termguicolors = true

local function get_flavor()
  local link = vim.fn.resolve(vim.fn.expand("~/.config/kitty/catppuccin.conf"))
  return link:match("latte") and "latte" or "mocha"
end

require("catppuccin").setup({ flavour = get_flavor() })
vim.cmd.colorscheme("catppuccin")
