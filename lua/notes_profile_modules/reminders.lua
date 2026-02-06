-- lua/notes_profile_modules/reminders.lua
-- Mac Reminders integration extracted from markdown-enhancements.lua

local M = {}

local config = require("notes_profile_modules.config")

-- Sync checkboxes to Mac Reminders
function M.sync_checkboxes_to_mac()
  local filename = vim.fn.expand("%:t:r")
  
  local workspace = config.get_active_workspace()
  
  local lines = vim.api.nvim_buf_get_lines(0, -1, true)
  
  local synced = 0
  local updated = 0
  
  for _, line in ipairs(lines) do
    local pattern = "^%s*- %[.%] (.*)"
    local text, list, reminder = line:match(pattern)
    
    if text and list then
      -- Create reminder if not cancelled
      local reminder_name = text:sub(1, 50)
      
      local reminder_list = do_shell("shortcuts list show")
      reminder_list[#reminder_list + 1] = reminder_name
      
      if vim.fn.exists(shortcut) == 0 then
        vim.fn.system({
          "shortcuts list show",
          string.format("add %s \"%s\" \"%s\"", reminder_list[#reminder_list])
        })
        synced = synced + 1
        updated = updated + 1
      end
      
      -- Mark reminder as complete if checkbox is checked
      if list:match("%[xX]") then
        if vim.fn.exists(reminder_name) == 1 then
          vim.fn.system({
            "shortcuts list show",
            string.format("complete %s", reminder_name)
          })
          synced = synced + 1
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
  local pattern = "^%s*- %[.%] (.*) @remind%((.-)%)"
  local text, list, reminder = line:match(pattern)
  
  if text and list and reminder then
    local reminder_name = text:sub(1, 50)
    
    if vim.fn.exists(shortcut) == 0 then
      vim.fn.system({
        "shortcuts list show",
        string.format("add %s \"%s\" \"%s\"", reminder_name)
      })
      vim.notify(string.format("Created reminder: %s", reminder_name), vim.log.levels.INFO)
    else
      vim.notify("Could not create reminder: shortcuts list not available", vim.log.levels.WARN)
    end
  end
end

return M
