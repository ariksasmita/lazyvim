-- Custom foldtext function for markdown files
-- Shows heading icons in closed folds instead of raw ### text
-- Shows code block language and line count for folded code blocks

local M = {}

-- Heading icons for each level
M.heading_icons = {
  '󰉋 ',  -- H1
  '󰉌 ',  -- H2
  '󰉏 ',  -- H3
  '󰉑 ',  -- H4
  '󰉒 ',  -- H5
  '󰉓 ',  -- H6
}

-- Custom fold text function for markdown
function M.markdown_foldtext()
  local line = vim.fn.getline(vim.v.foldstart)

  -- Check if it's a markdown heading (# H1, ## H2, etc.)
  local level = line:match('^(#+)%s')

  if level then
    local heading_level = #level

    -- Extract the heading text (remove the ###)
    local heading_text = line:gsub('^#+%s*', '')

    -- Get fold info
    local fold_size = vim.v.foldend - vim.v.foldstart + 1
    local line_count = ' [' .. fold_size .. ' lines]'

    -- Build the fold text with icon
    local icon = M.heading_icons[heading_level] or '󰉎 '
    return icon .. heading_text .. line_count
  end

  -- For non-headings, use default fold text
  return vim.fn.foldtext()
end

return M
