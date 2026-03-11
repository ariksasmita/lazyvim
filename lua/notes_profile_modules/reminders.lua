-- lua/notes_profile_modules/reminders.lua
-- Mac Reminders integration extracted from markdown-enhancements.lua

local M = {}

local config = require("notes_profile_modules.config")

-- Sync checkboxes to Mac Reminders
function M.sync_checkboxes_to_mac()
  local filename = vim.fn.expand("%:t:r")

  local workspace = config.get_active_workspace()

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local synced = 0
  local updated = 0

  for _, line in ipairs(lines) do
    local pattern = "^%s*- %[.%] (.*)"
    local text = line:match(pattern)

    if text then
      -- Create reminder if not cancelled
      local reminder_name = text:sub(1, 50)

      -- Check if reminder already exists
      local result = vim.fn.system("shortcuts list 2>/dev/null || true")

      if not result:match(reminder_name) then
        vim.fn.system({
          "shortcuts",
          "run",
          '"Reminders: Create Reminder"',
          "--input-text",
          reminder_name
        })
        if vim.v.shell_error == 0 then
          synced = synced + 1
        end
      end

      -- Mark reminder as complete if checkbox is checked
      if line:match("%[xX%]") then
        vim.fn.system({
          "shortcuts",
          "run",
          '"Reminders: Complete Reminder"',
          "--input-text",
          reminder_name
        })
        if vim.v.shell_error == 0 then
          updated = updated + 1
        end
      end
    end
  end

  if synced > 0 then
    vim.notify(string.format("Synced %d items to Mac Reminders", synced), vim.log.levels.INFO)
  end

  if updated > 0 then
    vim.notify(string.format("Updated %d Mac Reminders", updated), vim.log.levels.INFO)
  end
end

-- Create reminder for current line
function M.create_reminder_from_line()
  local line = vim.api.nvim_get_current_line()
  local pattern = "^%s*- %[.%] (.*)"
  local text = line:match(pattern)

  if text then
    local reminder_name = text:sub(1, 50)

    local result = vim.fn.system({
      "shortcuts",
      "run",
      '"Reminders: Create Reminder"',
      "--input-text",
      reminder_name
    })

    if vim.v.shell_error == 0 then
      vim.notify(string.format("Created reminder: %s", reminder_name), vim.log.levels.INFO)
    else
      vim.notify("Could not create reminder", vim.log.levels.WARN)
    end
  else
    vim.notify("Current line is not a checkbox item", vim.log.levels.WARN)
  end
end

return M
