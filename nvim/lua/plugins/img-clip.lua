return {
  "HakonHarnes/img-clip.nvim",
  cmd = "PasteImage",
  opts = {
    default = {
      dir_path = function()
        local dir = vim.fn.expand("%:p:h")
        while dir ~= "/" do
          if vim.uv.fs_stat(dir .. "/mkdocs.yml") then
            return dir .. "/assets"
          end
          dir = vim.fn.fnamemodify(dir, ":h")
        end
        return "assets"
      end,
    },
  },
}
