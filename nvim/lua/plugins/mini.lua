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

		-- When there's a WORD ahead, an opening bracket wraps it (up to the next
		-- whitespace, à la Vim's `W`) instead of inserting an empty pair: `|foo-bar`
		-- + `(` gives `(|foo-bar)`. With nothing wrappable ahead (whitespace or end
		-- of line) it falls back to normal autopair.
		--
		-- The span stops before a closing bracket so the inserted closer never jumps
		-- past the closer of a pair we're inside: `(|foo)` + `[` gives `([|foo])`,
		-- not `([|foo)]`.
		--
		-- Both branches return raw termcodes with replace_keycodes = false, matching
		-- how mini.pairs maps its own expr mappings. <C-g>U before each arrow keeps
		-- the wrap within one undo step (same trick mini.pairs uses internally).
		local tc = function(s)
			return vim.api.nvim_replace_termcodes(s, true, false, true)
		end
		local right, left = tc("<C-g>U<Right>"), tc("<C-g>U<Left>")

		-- Length of the WORD ahead of the cursor, stopping at whitespace or a
		-- closing bracket. col is 1-based; line:sub(col) is text from the cursor on.
		local function word_len(col, line)
			return #(line:sub(col):match("^[^%s)%]}]+") or "")
		end

		local function opener(pair)
			local open_ch, close_ch = pair:sub(1, 1), pair:sub(2, 2)
			return function()
				local n = word_len(vim.fn.col("."), vim.api.nvim_get_current_line())
				if n > 0 then
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

		local function quoter(pair)
			local ch = pair:sub(1, 1)
			return function()
				local n = word_len(vim.fn.col("."), vim.api.nvim_get_current_line())
				if n > 0 then
					return ch .. right:rep(n) .. ch .. left:rep(n + 1)
				end
				return pairs.closeopen(pair, "[^\\].")
			end
		end

		for _, q in ipairs({ '""', "''", "``" }) do
			vim.keymap.set("i", q:sub(1, 1), quoter(q), {
				expr = true,
				replace_keycodes = false,
				desc = "Autopair, or wrap next word with " .. q,
			})
		end
	end,
}
