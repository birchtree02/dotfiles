return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
        layout_strategy = "vertical",
        layout_config = {
            height = 0.95,
            prompt_position = "top",
            vertical = {
                mirror = true,
                preview_cutoff = 0,
            },
        },
    },
  },
}
