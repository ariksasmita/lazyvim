-- lua/notes_profile_modules/checkbox-core.lua
-- Extracted checkbox functions from markdown-enhancements.lua

local M = {}

local config = require("notes_profile_modules.config")

-- Get checkbox state from config
function M.get_checkbox_state(symbol)
  for _, state in ipairs(config.checkbox_states) do
    if state.symbol == symbol then
      return state
    end
  end
  return config.checkbox_states[1]
end

-- Toggle checkbox state forward: [ ] → [-] → [x] → [_] → [ ]
function M.toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  local checkbox_pattern = "^(%s*)%- %[(.)%]%s*(.*)"
  local indent, symbol, rest = line:match(checkbox_pattern)

  if indent and symbol and rest then
    local current = M.get_checkbox_state(symbol)
    local next_state = M.get_next_checkbox_state(symbol)
    if next_state then
      local new_line = indent .. "- [" .. next_state.symbol .. "] " .. rest
      vim.api.nvim_set_current_line(new_line)
    else
      local new_line = indent .. "- [ ] " .. rest
      vim.api.nvim_set_current_line(new_line)
    end
  end
end

-- Get next checkbox state
function M.get_next_checkbox_state(symbol)
  local current = M.get_checkbox_state(symbol)
  return M.get_checkbox_state(current.next)
end

-- Move checked item to DONE section
-- Moves the checkbox under cursor (and its children) to the ## DONE section
function M.move_checked_to_done()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_get_current_line()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]

  -- Check if current line is a checked checkbox
  if not line:match("%[x%]") then
    vim.notify("Current line is not a checked checkbox.", vim.log.levels.WARN)
    return
  end

  -- Find the ## DONE section
  local done_section_lnum = nil
  local buffer_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for i, bline in ipairs(buffer_lines) do
    if bline:match("^#+%s*DONE") then
      done_section_lnum = i
      break
    end
  end

  if not done_section_lnum then
    vim.notify("No '## DONE' section found in the file. Create one first!", vim.log.levels.WARN)
    return
  end

  -- Get the checkbox line and calculate its indentation
  local checkbox_line = buffer_lines[lnum]
  local checkbox_indent = checkbox_line:match("^(%s*)")
  local checkbox_indent_len = #checkbox_indent

  -- Collect the checkbox line and all its child lines (with greater indentation)
  local lines_to_move = { checkbox_line }
  local end_line = lnum

  -- Look for child lines (lines with greater indentation than the checkbox)
  for i = lnum + 1, #buffer_lines do
    local next_line = buffer_lines[i]

    -- Empty lines are considered part of the block
    if next_line:match("^%s*$") then
      table.insert(lines_to_move, next_line)
      end_line = i
    else
      -- Calculate indentation of the next line
      local next_indent = next_line:match("^(%s*)")
      local next_indent_len = #next_indent

      -- If next line has greater indentation, it's a child
      if next_indent_len > checkbox_indent_len then
        table.insert(lines_to_move, next_line)
        end_line = i
      else
        -- Stop when we hit a line with same or less indentation
        break
      end
    end
  end

  -- Remove the lines from their current position
  vim.api.nvim_buf_set_lines(bufnr, lnum - 1, end_line, false, {})

  -- Trim trailing empty lines from lines_to_move
  while #lines_to_move > 0 and lines_to_move[#lines_to_move]:match("^%s*$") do
    table.remove(lines_to_move)
  end

  -- Insert the lines after the DONE section header
  -- Adjust done_section_lnum if it's after the deleted lines
  local insert_pos = done_section_lnum
  if done_section_lnum > lnum then
    insert_pos = done_section_lnum - (end_line - lnum + 1)
  end

  vim.api.nvim_buf_set_lines(bufnr, insert_pos, insert_pos, false, lines_to_move)

  local item_count = #lines_to_move
  if item_count == 1 then
    vim.notify("Moved checked item to '## DONE' section.", vim.log.levels.INFO)
  else
    vim.notify(string.format("Moved checked item with %d child line(s) to '## DONE' section.", item_count - 1), vim.log.levels.INFO)
  end
end

-- Insert checkbox below current line
function M.insert_checkbox_below()
  local line = vim.api.nvim_get_current_line()
  local indent = line:match("^(%s*)")
  local checkbox = indent .. "- [ ] "

  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, lnum, lnum, false, {checkbox})
  vim.api.nvim_win_set_cursor(0, {lnum + 1, #checkbox})
  vim.cmd("startinsert!")
end

return M
