-- Disable breadcrumbs in lualine statusline (we use winbar instead)
return {
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        globalstatus = vim.o.laststatus == 3,
      },
      sections = {
        lualine_c = {
          -- Override LazyVim's default to remove breadcrumbs
          -- Just show root directory and filename
          {
            "filetype",
            icon_only = true,
            separator = "",
            padding = { left = 1, right = 0 },
          },
          { "filename", path = 1 }, -- 1 = relative path
        },
      },
    },
  },
}
