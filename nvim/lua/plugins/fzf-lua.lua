return {
  "ibhagwan/fzf-lua",
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "fzf-lua" },
    { "<leader>fw", "<cmd>FzfLua grep<CR><CR>", desc = "fzf-lua" },
  },
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "nvim-mini/mini.icons" },
  ---@module "fzf-lua"
  ---@type fzf-lua.Config|{}
  ---@diagnostic disable: missing-fields
  opts = {}
  ---@diagnostic enable: missing-fields
}
