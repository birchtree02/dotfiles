return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree" },
	},
	opts = {
		renderer = { group_empty = true },
	},
	config = function(_, opts)
		require("nvim-tree").setup(opts)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "NvimTree",
			callback = function()
				vim.schedule(function()
					vim.wo.statuscolumn = ""
				end)
			end,
		})
	end,
}
