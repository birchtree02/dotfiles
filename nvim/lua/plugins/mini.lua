return {
	"nvim-mini/mini.pairs",
	event = "VeryLazy",
	opts = {
		modes = { insert = true, command = true, terminal = false },
		-- NB: skip_next / skip_ts / skip_unbalanced / markdown are LazyVim wrapper
		-- options, not native mini.pairs ones. This spec passes opts straight to
		-- mini.pairs.setup(), which ignores them, so they were inert and are dropped.
	},
	config = function(_, opts)
		local pairs = require("mini.pairs")
		pairs.setup(opts)

		-- When the next character is a letter or digit, an opening bracket wraps
		-- the following word instead of inserting an empty pair: `|foo` + `(` gives
		-- `(|foo)`. Any other next char falls back to mini.pairs' normal autopair.
		--
		-- Both branches return raw termcodes with replace_keycodes = false, matching
		-- how mini.pairs maps its own expr mappings. <C-g>U before each arrow keeps
		-- the wrap within one undo step (same trick mini.pairs uses internally).
		local tc = function(s)
			return vim.api.nvim_replace_termcodes(s, true, false, true)
		end
		local right, left = tc("<C-g>U<Right>"), tc("<C-g>U<Left>")

		local function opener(pair)
			local open_ch, close_ch = pair:sub(1, 1), pair:sub(2, 2)
			return function()
				local col = vim.fn.col(".")
				local line = vim.api.nvim_get_current_line()
				if line:sub(col, col):match("%w") then
					local n = #(line:sub(col):match("^[%w_]+") or "")
					return open_ch .. right:rep(n) .. close_ch .. left:rep(n + 1)
				end
				-- "^[^\\]" is mini.pairs' default open neighbourhood pattern.
				return pairs.open(pair, "^[^\\]")
			end
		end

		for _, pair in ipairs({ "()", "[]", "{}" }) do
			vim.keymap.set("i", pair:sub(1, 1), opener(pair), {
				expr = true,
				replace_keycodes = false,
				desc = "Autopair, or wrap next word with " .. pair,
			})
		end
	end,
}
