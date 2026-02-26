-- Markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true

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

-- Java
vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
	end,
})
