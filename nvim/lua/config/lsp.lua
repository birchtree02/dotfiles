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
  }
})

-- Improve LSP settings for nvim config
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        -- Neovim uses LuaJIT
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` globals
        globals = {
          'vim',
          'require'
        },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  },
})
