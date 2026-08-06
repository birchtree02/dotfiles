return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		-- The main-branch API compiles parsers with the external tree-sitter CLI.
		-- Without it, install() fails and never registers the parser, so it retries
		-- (and errors) on every startup. Skip installing when the CLI is absent.
		if vim.fn.executable("tree-sitter") == 0 then
			vim.notify(
				"nvim-treesitter: `tree-sitter` CLI not found; skipping parser install. Run quick-setup.sh nvim or `brew install tree-sitter`.",
				vim.log.levels.WARN
			)
			return
		end
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
