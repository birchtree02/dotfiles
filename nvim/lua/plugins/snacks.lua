-- Pattern is concatenated so this file isn't matched by the search itself.
local TODO_PATTERN = "TO" .. "DO-"

local function get_todos()
	-- rg respects .gitignore (much faster than grep -rn) and returns file:line:text.
	-- awk reformats so the marker text is left-aligned and file:line trails for sorting.
	-- sort orders by the dash-separated numeric fields in the marker (TODO-A-B-C).
	local cmd = ([[rg --no-heading --line-number --color=never -g '!build' -- '%s' | awk -F: '{printf("%%-60s %%s:%%s\n", substr($0, index($0, "%s")), $1, $2);}' | sort -t - -k 2 -k 4 -k 6 -n]]):format(
		TODO_PATTERN,
		TODO_PATTERN:sub(1, -2)
	)
	local items = {}
	for _, line in ipairs(vim.fn.systemlist(cmd)) do
		local text, file, lnum = line:match("^(.-)%s+([^:]+):(%d+)$")
		if file and lnum and text then
			local trimmed = vim.trim(text)
			items[#items + 1] = {
				file = file:gsub("^%./", ""),
				text = trimmed,
				pos = { tonumber(lnum), 0 },
				-- IGNORE token (case-insensitive) anywhere after the marker tags
				-- the TODO as ignored; cursor will skip past it on picker open.
				ignored = trimmed:match("%f[%w]IGNORE%f[%W]") ~= nil,
			}
		end
	end
	return items
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		-- Restrict every picker to vim's :pwd. files/grep already do this, but
		-- recent/oldfiles span all of $HOME by default; filter.cwd=true clips them.
		picker = {
			filter = { cwd = true },
		},
		explorer = {},
	},
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
				local items = get_todos()
				-- Cursor lands on the first non-IGNORE item so ignored ones at the
				-- top of the sort are visible but not in the way.
				local first_active = 1
				for i, item in ipairs(items) do
					if not item.ignored then
						first_active = i
						break
					end
				end
				Snacks.picker.pick({
					items = items,
					format = function(item)
						local filename = item.file:match("([^/]+)$")
						return { { item.text .. "  " .. filename .. " " .. item.pos[1] } }
					end,
					on_show = function(picker)
						if first_active > 1 then
							picker.list:move(first_active, true)
						end
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
