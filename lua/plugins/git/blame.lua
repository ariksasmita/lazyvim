return {

  {
    "FabijanZulj/blame.nvim",
    cmd = { "BlameToggle" },
    config = function()
      require("blame").setup()
    end,
    keys = {
      { "<leader>gb", "<cmd>BlameToggle<CR>", desc = "blame panel" },
    },
  },
}
