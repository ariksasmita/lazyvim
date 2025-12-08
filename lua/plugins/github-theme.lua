-- return {
--   "projekt0n/github-nvim-theme",
--   lazy = false, -- Load the theme at startup
--   priority = 1000, -- Ensure it loads before other plugins
--   config = function()
--     require("github-theme").setup({
--       -- Options go here. For example:
--       -- theme_style = "dark", -- "dark", "dark_dimmed", "light", etc.
--     })
--     vim.cmd("colorscheme github_dark") -- Or your preferred style: github_dark, github_dark_dimmed, github_light, github_light_high_contrast, github_dark_high_contrast, github_light_colorblind, github_dark_colorblind
--   end,
-- }

return {
  -- Add github theme packages
  { "projekt0n/github-nvim-theme", name = "github", lazy = false, priority = 1000 },

  -- Make lazy use github theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "github_dark",
    }
  }
}
