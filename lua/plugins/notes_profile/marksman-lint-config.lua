-- lua/plugins/notes_profile/marksman-lint-config.lua
-- This file overrides marksman's settings to disable specific linting rules.

return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    -- Safely merge our custom settings with the existing marksman config
    opts.servers.marksman = vim.tbl_deep_extend("force", opts.servers.marksman or {}, {
      -- Set the root_dir to the git root or the current file's directory
      root_dir = function(fname)
        if type(fname) ~= "string" then
          return nil
        end
        return require("lspconfig.util").find_git_ancestor(fname) or vim.fn.fnamemodify(fname, ":h")
      end,
      -- Custom linting settings
      settings = {
        markdown = {
          diagnostics = {
            disable = { "MD012", "MD013", "MD034", "MD039" },
          },
        },
      },
    })
  end,
}
