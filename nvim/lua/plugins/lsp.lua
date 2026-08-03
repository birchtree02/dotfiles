return {
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim" },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      -- The whole exclude list lives here, even for servers only the work
      -- submodule cares about: lazy.nvim's opts merge replaces lists rather than
      -- concatenating them (lazy/core/util.lua:441), so a second exclude in
      -- another spec would silently drop this one.
      --
      -- jdtls is started by nvim-jdtls (see the work submodule), which needs to
      -- own the client to attach lombok and the bemol workspace folders.
      -- Excluding it here rather than there means a machine without the work
      -- submodule also won't auto-start a bare jdtls that shadows the
      -- configured one.
      --
      -- kotlin_language_server (fwcd) is superseded by kotlin_lsp, but
      -- mason-lspconfig auto-enables every installed package rather than only
      -- ensure_installed ones (automatic_enable.lua:56). Any machine that
      -- installed it earlier would otherwise still start it, and it attaches
      -- first, so excluding it by name is what actually pins the choice.
      automatic_enable = { exclude = { "jdtls", "kotlin_language_server" } },
    },
  },
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
}
