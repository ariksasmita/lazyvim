-- lua/plugins/markdown-theming.lua
-- This script sets up autocommands to automatically switch the colorscheme
-- for markdown files. It follows the simple pattern of local configuration
-- files by returning an empty table at the end.

local default_theme = "github_dark_high_contrast"
local markdown_theme = "github_light_high_contrast"

-- Helper function to apply a colorscheme if it's not already active
local function apply_colorscheme(theme)
  if vim.g.colors_name ~= theme then
    -- Use pcall to prevent errors if the colorscheme doesn't exist
    pcall(vim.cmd, "colorscheme " .. theme)
  end
end

-- Helper function to check if any visible window in the current tabpage contains a markdown buffer
local function has_visible_markdown_buffer()
  for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    if vim.api.nvim_buf_get_option(buf_id, 'filetype') == 'markdown' then
      return true
    end
  end
  return false
end

-- Create an autocmd group to manage these rules, clearing it to prevent duplicates
local augroup = vim.api.nvim_create_augroup("MarkdownColorscheme", { clear = true })

-- Rule 1: On entering any buffer
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "markdown" then
      apply_colorscheme(markdown_theme)
    else
      if not has_visible_markdown_buffer() then
        apply_colorscheme(default_theme)
      end
    end
  end,
})

-- Rule 2: On leaving a markdown buffer's window
vim.api.nvim_create_autocmd("BufWinLeave", {
  group = augroup,
  pattern = "*.md",
  callback = function()
    -- Delay the check slightly to handle rapid window/tab switching gracefully
    vim.defer_fn(function()
      if not has_visible_markdown_buffer() then
        apply_colorscheme(default_theme)
      end
    end, 10)
  end,
})

-- Rule 3: On startup, set the correct initial theme
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  callback = function()
    vim.defer_fn(function()
      if has_visible_markdown_buffer() then
        apply_colorscheme(markdown_theme)
      else
        apply_colorscheme(default_theme)
      end
    end, 10)
  end,
})

-- Return an empty table to be a valid, empty plugin spec for lazy.nvim
return {}
