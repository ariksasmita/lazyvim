return {
  -- Add github theme packages
  { "projekt0n/github-nvim-theme", name = "github", lazy = false, priority = 1000 },

  -- Make lazy use github theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "github_dark_high_contrast",
    }
  }
}
