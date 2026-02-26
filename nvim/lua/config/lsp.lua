require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		-- lua
		"lua_ls",
		"stylua",
		-- python
		"black",
		"pyright",
		-- bash
		"shfmt",
		-- java
		"jdtls",
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

-- Java LSP with Lombok support
-- vim.lsp.config('jdtls', {
-- cmd = {
-- 'jdtls',
-- '--jvm-arg=-javaagent:' .. vim.fn.expand('~/.local/share/nvim/mason/packages/jdtls/lombok.jar'),
-- },
-- })

-- Add borders to diagnostic windows
vim.diagnostic.config({
	float = {
		border = "rounded",
	},
})

-- Add borders to LSP hover and signature help
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "rounded",
})
