vim.o.termguicolors = true

local function get_flavor()
  local link = vim.fn.resolve(vim.fn.expand("~/.config/kitty/catppuccin.conf"))
  return link:match("latte") and "latte" or "mocha"
end

local function apply_theme()
  require("catppuccin").setup({ flavour = get_flavor() })
  vim.cmd.colorscheme("catppuccin")
end

apply_theme()

vim.api.nvim_create_autocmd("FocusGained", {
  callback = apply_theme,
})
