-- Disable noice.nvim due to E36 "Not enough room" crashes
-- TESTING: Re-enabled to see if crashes were caused by old markdown plugins instead
-- If crashes return, set enabled = false again
return {
  {
    "folke/noice.nvim",
    enabled = true,  -- TESTING - Re-enabled for command popup UI
  },
}
