return {
  "3rd/image.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  ft = { "markdown", "norg" },
  opts = {
    backend = "kitty", -- kitty protocol works with Ghostty and Warp
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = true, -- Only show when cursor is on the line
        filetypes = { "markdown", "vimwiki" },
      },
      neorg = {
        enabled = false,
      },
    },
    max_width = 80, -- Maximum width in columns
    max_height = 20, -- Maximum height in lines
    max_width_window_percentage = 40, -- Max 40% of window width for narrow splits
    max_height_window_percentage = 50, -- Max 50% of window height
    window_overlap_clear_enabled = true, -- Clear images when windows overlap
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    editor_only_render_when_focused = true, -- Only render in focused window
    tmux_show_only_in_active_window = true,
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- Show images when opening image files
  },
}
