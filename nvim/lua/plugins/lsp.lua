return {
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim" },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      -- jdtls is started by nvim-jdtls (see the work submodule), which needs to
      -- own the client to attach lombok and the bemol workspace folders.
      -- Excluding it here rather than there means a machine without the work
      -- submodule also won't auto-start a bare jdtls that shadows the
      -- configured one.
      automatic_enable = { exclude = { "jdtls" } },
    },
  },
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
}
