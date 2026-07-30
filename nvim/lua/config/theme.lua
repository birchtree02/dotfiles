vim.o.termguicolors = true

-- Flavour comes from the machine-local state file written by
-- scripts/apply-state.sh, the same source kitty and tmux read.
local function get_flavor()
	local state = vim.fn.expand("~/.local/state/dotfiles/theme")
	local lines = vim.fn.filereadable(state) == 1 and vim.fn.readfile(state) or {}
	local flavour = vim.trim(lines[1] or "")
	return flavour == "latte" and "latte" or "mocha"
end

require("catppuccin").setup({ flavour = get_flavor() })
vim.cmd.colorscheme("catppuccin")
