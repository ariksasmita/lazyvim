return {
  "folke/trouble.nvim",
  dependencies = { "folke/todo-comments.nvim", "nvim-tree/nvim-web-devicons" },
  opts = {}, -- use default settings
  keys = {
    {
      "<leader>xt",
      "<cmd>TodoTrouble<cr>",
      desc = "Todo (Trouble)",
    },
  },
}
