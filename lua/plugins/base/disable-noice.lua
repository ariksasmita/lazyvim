-- Disable noice.nvim due to E36 "Not enough room" crashes
-- snacks.nvim will handle notifications instead
return {
  {
    "folke/noice.nvim",
    enabled = false,
  },
}
