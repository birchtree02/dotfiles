return {
	"folke/persistence.nvim",
	event = "BufReadPre", -- this will only start session saving when an actual file was opened
  config = function()
    require("persistence").setup {
      dir = vim.fn.expand(vim.fn.stdpath "state" .. "/sessions/"),
      -- minimum number of file buffers that need to be open to save
      need = 1,
      options = { "buffers", "curdir", "tabpages", "winsize" },
    }
  end,
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
    { "<leader>qS", function() require("persistence").select() end, desc = "Select Session" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
  }
}
