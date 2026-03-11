-- lua/plugins/notes_profile/config.lua
-- Shared configuration for all notes_profile modules

local M = {}

-- ============================================================================
-- WORKSPACES CONFIGURATION
-- ============================================================================

M.workspaces = {
  work = vim.fn.expand("~/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault"),
  test = "/tmp/neorg-test-vault",
  -- Future workspaces can be added here:
  -- personal = "~/notes/personal",
  -- archive = "~/notes/archive",
}

M.default_workspace = "work"

-- Current active workspace (persisted across sessions)
M.active_workspace = nil

-- ============================================================================
-- PATH FUNCTIONS
-- ============================================================================

-- Get the current active workspace path
function M.get_workspace_path(workspace_name)
  workspace_name = workspace_name or M.get_active_workspace()
  return M.workspaces[workspace_name]
end

-- Get active workspace name
function M.get_active_workspace()
  if not M.active_workspace then
    M.active_workspace = M.load_active_workspace()
  end
  return M.active_workspace
end

-- Set active workspace and persist
function M.set_active_workspace(workspace_name)
  if not M.workspaces[workspace_name] then
    vim.notify("Workspace '" .. workspace_name .. "' does not exist", vim.log.levels.ERROR)
    return false
  end
  M.active_workspace = workspace_name
  M.save_active_workspace(workspace_name)
  return true
end

-- ============================================================================
-- PERSISTENCE (stores in ~/.local/state/nvim/)
-- ============================================================================

function M.get_state_file()
  local state_dir = vim.fn.stdpath("state") .. "/notes_profile"
  vim.fn.mkdir(state_dir, "p")
  return state_dir .. "/workspace.txt"
end

function M.save_active_workspace(workspace_name)
  local file = io.open(M.get_state_file(), "w")
  if file then
    file:write(workspace_name)
    file:close()
  end
end

function M.load_active_workspace()
  local file = io.open(M.get_state_file(), "r")
  if file then
    local workspace = file:read("*a"):gsub("%s+", "")
    file:close()
    if M.workspaces[workspace] then
      return workspace
    end
  end
  return M.default_workspace
end

-- ============================================================================
-- TIME TRACKING DATABASE PATHS
-- ============================================================================

M.time_db_dir = vim.fn.stdpath("data") .. "/notes_profile/time_logs"

function M.get_time_db_path(period)
  -- period format: "2025-12" or "2025-W52" (for weekly)
  vim.fn.mkdir(M.time_db_dir, "p")
  return M.time_db_dir .. "/" .. period .. ".json"
end

function M.get_current_period(type)
  -- type: "monthly" or "weekly"
  if type == "weekly" then
    return os.date("%Y-W%W")
  else
    return os.date("%Y-%m")
  end
end

-- ============================================================================
-- CHECKBOX STATE CONFIGURATION
-- ============================================================================

M.checkbox_states = {
  { symbol = " ", label = "Pending",     icon = "󰄱", next = "-" },
  { symbol = "-", label = "In Progress", icon = "󰔛", next = "x" },
  { symbol = "x", label = "Done",        icon = "󰄵", next = "_" },
  { symbol = "_", label = "Cancelled",   icon = "󰅰", next = " " },
}

function M.get_checkbox_state(symbol)
  for _, state in ipairs(M.checkbox_states) do
    if state.symbol == symbol then
      return state
    end
  end
  return M.checkbox_states[1] -- Default to pending
end

function M.get_next_checkbox_state(symbol)
  local current = M.get_checkbox_state(symbol)
  return M.get_checkbox_state(current.next)
end

-- ============================================================================
-- EXPORT TEMPLATES
-- ============================================================================

M.export_templates_dir = vim.fn.stdpath("config") .. "/lua/plugins/notes_profile/templates"

function M.get_template_path(type, name)
  -- type: "html", "pdf", "presentation"
  -- name: "minimal", "professional", etc.
  return M.export_templates_dir .. "/" .. type .. "-" .. name
end

-- ============================================================================
-- FEATURE FLAGS (for gradual rollout)
-- ============================================================================

M.features = {
  multi_state_checkboxes = true,  -- Enabled after Phase 11 ✅
  workspace_management = false,   -- Will be enabled after Phase 12
  time_tracking = false,          -- Will be enabled after Phase 13
  export_system = false,           -- Will be enabled after Phase 14
  text_objects = false,            -- Will be enabled after Phase 15
  analytics = false,               -- Will be enabled after Phase 16
}

function M.is_enabled(feature)
  return M.features[feature] == true
end

-- ============================================================================
-- WORKSPACE MANAGEMENT (Phase 12) - NEW IMPLEMENTATION
-- ============================================================================

M.workspace_management = {
  -- FEATURE FLAG: Set to true when ready to enable
  enabled = true,

  -- Workspace definitions
  workspaces = {
    default = {
      path = "/Users/sasmitai/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault",
      name = "Default (All Notes)",
    },
    -- Add more workspaces here when ready:
    work = {
      path = "/Users/sasmitai/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault/work",
      name = "Work",
    },
    personal = {
      path = "/Users/sasmitai/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault/personal",
      name = "Personal",
    },
    -- test = {
    --   path = "/tmp/neorg-test-vault",
    --   name = "Test",
    -- },
  },

  -- Currently active workspace
  active_workspace = "default",

  -- State persistence file (stores active workspace between sessions)
  state_file = vim.fn.stdpath("data") .. "/notes_workspace.json",
}

return M
