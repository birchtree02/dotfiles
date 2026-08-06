local workspace_path = vim.fn.expand("~/Documents/coding/notes_and_stuff")

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- use latest release, remove to use latest commit
	-- obsidian.nvim requires at least one valid workspace, so only load it when
	-- the notes directory exists on this machine. Otherwise setup() aborts with
	-- "At least one workspace is required!" on startup.
	cond = vim.fn.isdirectory(workspace_path) == 1,
	---@module 'obsidian'
	---@type obsidian.config
	opts = {
		legacy_commands = false, -- this will be removed in 4.0.0
		workspaces = {
			{
				name = "personal",
				path = workspace_path,
			},
		},
	},
}
