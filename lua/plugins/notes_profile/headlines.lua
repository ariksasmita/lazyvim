-- lua/plugins/headlines.lua
return {
  "lukas-reineke/headlines.nvim",
  config = function()
    require("headlines").setup()
  end,
}
