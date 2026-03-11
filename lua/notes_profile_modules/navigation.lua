-- lua/notes_profile_modules/navigation.lua
-- Navigation functions extracted from markdown-enhancements.lua

local M = {}

local config = require("notes_profile_modules.config")

-- Insert backlink at cursor position
function M.insert_backlink()
  local workspace_path = config.get_workspace_path()
  local current_file = vim.fn.expand("%:t")
  local relative_path = current_file

  local backlink = string.format("[%s](%s)", relative_path, relative_path)

  vim.api.nvim_put({backlink}, "", true, true)
  vim.cmd("normal!la")
  vim.notify("Inserted backlink to: " .. relative_path, vim.log.levels.INFO)
end

-- Search headings in workspace
function M.search_headings()
  local workspace_path = config.get_workspace_path()
  require("telescope.builtin").live_grep({
    prompt_title = "Search Headings",
    cwd = workspace_path,
    default_text = "^#+",
  })
end

-- Generate table of contents for current buffer
function M.generate_toc()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local toc = {}
  local toc_pattern = "^#+%s+(.*)$"

  for i, line in ipairs(lines) do
    local match = line:match(toc_pattern)
    if match then
      local level = #line:match("^(#+)")
      table.insert(toc, {
        level = level,
        text = match,
        line_num = i,
      })
    end
  end

  return toc
end

-- Full-text search in workspace
function M.full_text_search()
  local workspace_path = config.get_workspace_path()
  require("telescope.builtin").live_grep({
    prompt_title = "Full-Text Search",
    cwd = workspace_path,
    default_text = vim.fn.input("Search: ", ""),
  })
end

-- Get heading under cursor
function M.get_heading_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local heading = line:match("^#+%s+(.*)$")
  return heading
end

return M
