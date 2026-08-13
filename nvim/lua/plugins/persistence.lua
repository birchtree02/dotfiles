return {
	"folke/persistence.nvim",
	event = "BufReadPre", -- this will only start session saving when an actual file was opened
	init = function()
		-- Open the session picker when nvim starts with no file arguments — e.g.
		-- when tmux-resurrect relaunches a bare `nvim` in a restored pane. `nvim
		-- <file>` and piped stdin are left alone. Registered in init (not config)
		-- so the VimEnter hook exists before VimEnter fires; requiring persistence
		-- in the callback lazy-loads the plugin and runs setup() first.
		vim.api.nvim_create_autocmd("StdinReadPre", {
			callback = function()
				vim.g.persistence_stdin = true
			end,
		})
		vim.api.nvim_create_autocmd("VimEnter", {
			nested = true, -- let a chosen session fire its own BufReadPre/filetype autocmds
			callback = function()
				if vim.fn.argc(-1) == 0 and not vim.g.persistence_stdin then
					require("persistence").select()
				end
			end,
		})
	end,
  config = function()
    require("persistence").setup {
      dir = vim.fn.expand(vim.fn.stdpath "state" .. "/sessions/"),
      -- minimum number of file buffers that need to be open to save
      need = 1,
      options = { "buffers", "curdir", "tabpages", "winsize" },
    }
  end,
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
    { "<leader>qS", function() require("persistence").select() end, desc = "Select Session" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
  }
}
