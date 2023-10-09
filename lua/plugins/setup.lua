return {
  -- add moonfly
  { "bluz71/vim-moonfly-colors" },

  -- Config Lazyvim to load moonfly
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "moonfly",
    },
  },
}
