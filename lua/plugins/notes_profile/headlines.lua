-- lua/plugins/headlines.lua
-- DISABLED: Conflicts with markview.nvim (both render markdown)
-- Re-enabled by removing 'enabled = false' if needed
return {
  "lukas-reineke/headlines.nvim",
  enabled = false,  -- DISABLED - using markview.nvim instead
  config = function()
    require("headlines").setup()
  end,
}
