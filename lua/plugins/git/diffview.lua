return {

  {
    "dlyongemallo/diffview.nvim",
    lazy = false,
    enabled = true,
    config = function()
      require("plugins.git.diffview")
    end,
    keys = {
      { "<leader>gd", "<cmd>lua require('plugins.git.diffview').toggle_file_history()<CR>", desc = "diff file" },
      { "<leader>gD", "<cmd>lua require('diffview').open()<CR>", desc = "diff view open" },
      { "<leader>gS", "<cmd>lua require('plugins.git.diffview').toggle_status()<CR>", desc = "diff status" },
    },
  },
}
