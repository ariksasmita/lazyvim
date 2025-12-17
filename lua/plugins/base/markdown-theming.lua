-- lua/plugins/markdown-theming.lua
-- This script sets up autocommands to automatically switch the colorscheme
-- based on whether the current file is within the dedicated Markdown notes folder.

local default_theme = "moonfly"
local markdown_theme = "tokyonight-night" -- User's chosen Markdown theme
local markdown_base_path = vim.fn.expand("~/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault") -- User's dedicated Markdown folder


-- Helper function to apply a colorscheme if it's not already active
local function apply_colorscheme(theme)
  if vim.g.colors_name ~= theme then
    pcall(vim.cmd, "colorscheme " .. theme)
  end
end

-- Create an autocmd group to manage these rules, clearing it to prevent duplicates
local augroup = vim.api.nvim_create_augroup("MarkdownColorscheme", { clear = true })

-- Rule: On entering any buffer
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  pattern = "*",
  callback = function()
    -- Guard: Only run this logic for normal file buffers. Ignore internal buffers like Telescope.
    if vim.bo.buftype ~= "" then
      return
    end

    local current_file_path = vim.api.nvim_buf_get_name(0)

    -- Check if the current file's path starts with the markdown_base_path
    if current_file_path:find(markdown_base_path, 1, true) == 1 then
      apply_colorscheme(markdown_theme)
    else
      apply_colorscheme(default_theme)
    end
  end,
})

-- Rule: On startup, ensure the correct initial theme is set based on the current buffer
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  callback = function()
    -- Defer to allow the initial buffer to load and stabilize
    vim.defer_fn(function()
      local current_file_path = vim.api.nvim_buf_get_name(0)
      if current_file_path:find(markdown_base_path, 1, true) == 1 then
        apply_colorscheme(markdown_theme)
      else
        apply_colorscheme(default_theme)
      end
    end, 100) -- A slightly longer delay for VimEnter for robustness
  end,
})

-- Return an empty table to be a valid, empty plugin spec for lazy.nvim
return {}
