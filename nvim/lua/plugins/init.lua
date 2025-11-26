return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  {
    "nvim-java/nvim-java",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "jdtls",
        "black",
        "blackd-client",
        "eslint_d",
        "flake8",
        "jedi-language-server",
        "pyright",
        "typescript-language-server",
      },
      automatic_enable = {
        -- We will enable jdtls ourselves in attach_jdtls()
        exclude = { "jdtls" }
      }
    },
  },
  {
    "averms/black-nvim"
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
        "bash", "java", "promql", "sql",
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
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false
  }, 

}
