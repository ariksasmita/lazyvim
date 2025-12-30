return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- Ensure we have ensure_installed table
    opts.ensure_installed = opts.ensure_installed or {}
    
    -- Add common parsers but exclude vim (due to query bug)
    vim.list_extend(opts.ensure_installed, {
      "bash",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "regex",
      -- "vim",  -- Disabled due to query file bug with "tab" node
      "vimdoc",
    })
    
    -- Disable auto-install to prevent Mason tree-sitter-cli errors
    -- (tree-sitter-cli is now installed system-wide via homebrew)
    opts.auto_install = false
    
    -- Disable treesitter for vim files due to incompatible query file
    opts.highlight = opts.highlight or {}
    opts.highlight.enable = true
    opts.highlight.disable = { "vim" }
    
    return opts
  end,
}
