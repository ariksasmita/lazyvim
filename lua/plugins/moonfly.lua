return {
  -- Add moonfly packages
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },

  -- Make lazy use moonfly
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "moonfly",
    },
  },
}
