return {
  "akinsho/bufferline.nvim",
  config = function()
    require("bufferline").setup({
      options = {
        buffer_close_icon = "x",
        offsets = {
          {
            filetype = "NvimTree",
            text = "NvimTree",
            separator = true,
          }
        }
      }
    })
  end
}
