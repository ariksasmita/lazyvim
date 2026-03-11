-- Add search keybinding fallback
return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>sg",
        function()
          -- Fallback to telescope live_grep if snacks picker fails
          local ok = pcall(function()
            require("telescope.builtin").live_grep()
          end)
          if not ok then
            vim.notify("Telescope live_grep failed", vim.log.levels.ERROR)
          end
        end,
        desc = "Search in files (Telescope fallback)",
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      -- Make sure telescope has good defaults
      if not opts.defaults then
        opts.defaults = {}
      end
      opts.defaults.file_ignore_patterns = {
        "%.git/",
        "%.png",
        "%.jpg",
        "%.jpeg",
      }
      return opts
    end,
  },
}
