local todo_cache = {}

local function update_todos()
	local cmd =
		[[grep -rn --exclude-dir build 'TO''DO-' . | awk -F : '{printf("%-60s %s:%s\n", substr($0, index($0, "TO" "DO")), $1, $2);}' | sort -t - -k 2 -k 4 -k 6 -n]]
	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			local items = {}
			for _, line in ipairs(data) do
				if line ~= "" then
					local file, lnum = line:match("%s+([^:]+):(%d+)$")
					local text = line:match("^(.-)%s+[^%s]+$")
					if file and lnum and text then
						file = file:gsub("^%./", "")
						table.insert(items, { file = file, text = vim.trim(text), pos = { tonumber(lnum), 0 } })
					end
				end
			end
			todo_cache = items
		end,
	})
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		picker = {},
		explorer = {},
	},
	init = function()
		update_todos()
		vim.api.nvim_create_autocmd("BufWritePost", {
			callback = update_todos,
		})
	end,
	keys = {
		-- Top Pickers & Explorer
		{
			"<leader><space>",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader>,",
			function()
				Snacks.picker.buffers({
					sort_lastused = true,
					on_show = function(picker)
						vim.cmd("stopinsert")
						picker.list:move(1)
					end,
				})
			end,
			desc = "Buffers",
		},
		{
			"<leader>fw",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>:",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>n",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Notification History",
		},
		{
			"<leader>ft",
			function()
				Snacks.picker.pick({
					items = todo_cache,
					format = function(item)
						local filename = item.file:match("([^/]+)$")
						return { { item.text .. " " .. filename .. ":" .. item.pos[1] } }
					end,
					win = {
						input = {
							keys = {
								i_esc = { "<esc>", "close", mode = "i" },
							},
						},
					},
				})
				vim.schedule(function()
					vim.cmd("stopinsert")
				end)
			end,
			desc = "Find TODOs (sorted)",
		},
	},
}
