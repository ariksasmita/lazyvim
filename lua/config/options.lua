-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
-- Disable LazyVim auto formatting
vim.g.autoformat = false

-- Enable breakindent for proper wrapped line indentation
-- This ensures wrapped lines preserve the indentation of the original line
-- which is essential for markdown lists, code blocks, and other structured text
vim.opt.breakindent = true

-- Configure breakindent behavior:
-- shift: Number of spaces to add for each level of nested indentation
-- min: Minimum indentation for wrapped lines (prevents text going too far left)
-- sbr: Include 'showbreak' string in the indentation calculation
vim.opt.breakindentopt = "shift:2,min:20,sbr"

-- String to show at the start of wrapped lines (optional visual indicator)
-- You can change this to "↪ " or "… " or "" (empty) if you prefer
vim.opt.showbreak = "   "  -- Three spaces to align with original indentation
