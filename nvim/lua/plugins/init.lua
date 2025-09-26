return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "williamboman/mason-lspconfig.nvim",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "ojroques/nvim-bufdel",
    keys = {
      {"<leader>bd", ":BufDel<CR>"}
    },
    opts = {
      quit = false,
    }
  },
  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
  			"vim", "lua", "vimdoc",
       "html", "css", "markdown", "python"
  		},
  	},
  },
  {
    "xiyaowong/transparent.nvim",
    lazy=false,
    opts = {
      extra_groups = {
        "NvimTreeNormal"
      }
    }
  }
}
