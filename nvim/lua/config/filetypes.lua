-- Markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true

		-- Visual P: wrap the selection as a markdown link, taking the URL from the
		-- system clipboard. With clipboard=unnamedplus the register `p` actually
		-- pastes is "+" (read via the OS provider); the unnamed register `"` only
		-- holds what was last yanked inside nvim, so it misses a link copied in the
		-- browser. Read "+" first — before the change clobbers the registers — and
		-- stash it in register l, then rebuild the text as [selection](url). Fed
		-- with the 'n' flag so the inserted () and [] don't trigger mini.pairs.
		vim.keymap.set("x", "P", function()
			local url = vim.trim(vim.fn.getreg("+"))
			local save_reg, save_type = vim.fn.getreg("l"), vim.fn.getregtype("l")
			vim.fn.setreg("l", url)
			local keys = vim.api.nvim_replace_termcodes('c[<C-r>"](<C-r>l)<Esc>', true, false, true)
			vim.api.nvim_feedkeys(keys, "nx", false)
			vim.fn.setreg("l", save_reg, save_type)
		end, { buffer = true, desc = "Wrap selection as markdown link (URL from default register)" })

		-- Define snippets
		local luasnip = require("luasnip")
		luasnip.add_snippets("markdown", {
			luasnip.snippet("today", {
				luasnip.function_node(function()
					return os.date("%A %Y-%m-%d")
				end),
			}),
			luasnip.snippet("tomorrow", {
				luasnip.function_node(function()
					return os.date("%A %Y-%m-%d", os.time() + 86400)
				end),
			}),
			luasnip.snippet("tomorrow_wd", {
				luasnip.function_node(function()
					local tomorrow = os.time() + 86400
					local wday = tonumber(os.date("%w", tomorrow))
					if wday == 0 then -- Sunday -> Monday
						tomorrow = tomorrow + 86400
					elseif wday == 6 then -- Saturday -> Monday
						tomorrow = tomorrow + 172800
					end
					return os.date("%A %Y-%m-%d", tomorrow)
				end),
			}),
		})

		-- Only show snippet completions
		local cmp = require("cmp")
		cmp.setup.buffer({
			sources = {
				{ name = "luasnip" },
			},
		})
	end,
})

-- Java / Kotlin
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "java", "kotlin" },
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
	end,
})
