-- lua/plugins/notes_profile/conform.lua
-- Configures conform.nvim for auto-formatting Markdown files with Prettier.

return {
  "stevearc/conform.nvim",
  opts = {
    -- Use prettier for markdown files.
    formatters_by_ft = {
      markdown = { "prettier" },
    },
    -- LazyVim handles format_on_save automatically.
  },
  -- Optional: Add a keymap to manually format the buffer
  keys = {
    {
      "<leader>fm",
      function()
        require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
      end,
      mode = "", -- apply in normal and visual mode
      desc = "Format buffer",
    },
  },
}
