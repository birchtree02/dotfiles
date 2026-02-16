return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
	},
	config = function()
		local cmp = require("cmp")
    local luasnip = require('luasnip')

    -- Define snippets
    luasnip.add_snippets('markdown', {
      luasnip.snippet('today', {
        luasnip.function_node(function()
          return os.date('%A %Y-%m-%d')
        end)
      }),
      luasnip.snippet('tomorrow', {
        luasnip.function_node(function()
          return os.date('%A %Y-%m-%d', os.time() + 86400)
        end)
      }),
      luasnip.snippet('tomorrow_wd', {
        luasnip.function_node(function()
          local tomorrow = os.time() + 86400
          local wday = tonumber(os.date('%w', tomorrow))
          if wday == 0 then -- Sunday -> Monday
            tomorrow = tomorrow + 86400
          elseif wday == 6 then -- Saturday -> Monday
            tomorrow = tomorrow + 172800
          end
          return os.date('%A %Y-%m-%d', tomorrow)
        end)
      })
    })

		cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
			mapping = cmp.mapping.preset.insert({
				["<C-Space>"] = cmp.mapping.complete(),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<Tab>"] = cmp.mapping.select_next_item(),
				["<S-Tab>"] = cmp.mapping.select_prev_item(),
			}),
			sources = {
        { name = 'luasnip' }, -- snippets
				{ name = "nvim_lsp" },
				{ name = "buffer" },
				{ name = "path" },
			},
			window = {
				completion = cmp.config.window.bordered({
					border = "rounded", -- 'single', 'double', 'rounded', 'solid', 'shadow'
					winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
				}),
				documentation = cmp.config.window.bordered({
					border = "rounded",
				}),
			},
			formatting = {
				format = function(entry, item)
					item.menu = ({
						nvim_lsp = "[LSP]",
						buffer = "[Buffer]",
						path = "[Path]",
					})[entry.source.name]
					return item
				end,
			},
		})
	end,
}
