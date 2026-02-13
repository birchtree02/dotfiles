local map = vim.keymap.set

-- buffers
map("n", "<tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>f", "<cmd>lua vim.lsp.buf.format()<cr>", { desc = "Format file" })
map("n", "<leader>x", function()
	require("snacks").bufdelete()
end, { desc = "Delete buffer" })

-- commenting
map("n", " /", "<cmd>normal gcc<cr><cr>", { desc = "Comment Line" })
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- open
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>m", "<cmd>Mason<cr>", { desc = "Mason" })

-- diagnostic
local diagnostic_goto = function(next, severity)
	return function()
		vim.diagnostic.jump({
			count = (next and 1 or -1) * vim.v.count1,
			severity = severity and vim.diagnostic.severity[severity] or nil,
			float = true,
		})
	end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
