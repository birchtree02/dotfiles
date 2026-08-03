return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local parsers = { "bash", "vim", "lua", "vimdoc", "html", "css", "markdown", "markdown_inline", "python", "java", "kotlin", "yaml", "json" }
		local installed = require("nvim-treesitter").get_installed()
		local to_install = vim.tbl_filter(function(p)
			return not vim.list_contains(installed, p)
		end, parsers)
		if #to_install > 0 then
			require("nvim-treesitter").install(to_install)
		end
	end,
}
