require("mason").setup()
-- No opts here on purpose: mason-lspconfig's settings come from the plugin spec
-- in lua/plugins/lsp.lua. Passing a table would deep-merge over those settings
-- and clobber the automatic_enable exclude list that keeps jdtls off.
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		-- lua
		"lua_ls",
		"stylua",
		-- python
		"black",
		"pyright",
		-- java
		-- jdtls is installed via mason-lspconfig's ensure_installed and started
		-- by nvim-jdtls, not by mason's automatic_enable. See lua/plugins/lsp.lua.
		-- bash
		"shfmt",
	},
	auto_update = true,
})

-- Improve LSP settings for nvim config
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				-- Neovim uses LuaJIT
				version = "LuaJIT",
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` globals
				globals = {
					"vim",
					"require",
				},
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})

-- Java (jdtls) is deliberately not configured here. nvim-jdtls owns it so that
-- lombok, bemol workspace folders and the extended code actions all apply; a
-- vim.lsp.config("jdtls") block here would fight that with a second -data dir.

-- Add borders to diagnostic windows
vim.diagnostic.config({
	float = {
		border = "rounded",
	},
})

-- Add borders to LSP hover and signature help. vim.lsp.with() was removed in
-- Nvim 0.12; the border is now passed straight to the vim.lsp.buf functions.
local orig_hover = vim.lsp.buf.hover
vim.lsp.buf.hover = function(opts)
	return orig_hover(vim.tbl_extend("force", { border = "rounded" }, opts or {}))
end

local orig_signature_help = vim.lsp.buf.signature_help
vim.lsp.buf.signature_help = function(opts)
	return orig_signature_help(vim.tbl_extend("force", { border = "rounded" }, opts or {}))
end
