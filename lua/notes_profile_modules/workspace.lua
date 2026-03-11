-- Workspace Management Module
-- Allows organizing notes into separate workspaces (work, personal, test, etc.)
-- SAFETY: Feature flag enabled = false by default - safe rollout

local M = {}

local config = require("notes_profile_modules.config")

-- Expand home directory in path
local function expand_path(path)
  return path:gsub("^~", vim.fn.expand("~"))
end

-- Check if workspace management is enabled
function M.is_enabled()
  return config.workspace_management and config.workspace_management.enabled == true
end

-- Get active workspace config
function M.get_active_workspace()
  if not M.is_enabled() then
    return nil
  end

  local active_name = config.workspace_management.active_workspace or "default"
  local workspace = config.workspace_management.workspaces and config.workspace_management.workspaces[active_name]

  if not workspace then
    vim.notify("Workspace '" .. active_name .. "' not found in config", vim.log.levels.ERROR)
    return nil
  end

  return {
    name = active_name,
    display_name = workspace.name or active_name,
    path = expand_path(workspace.path),
  }
end

-- List all available workspaces
function M.list_workspaces()
  if not M.is_enabled() then
    return {}
  end

  local workspaces = {}
  for name, workspace in pairs(config.workspace_management.workspaces or {}) do
    table.insert(workspaces, {
      name = name,
      display_name = workspace.name or name,
      path = expand_path(workspace.path),
    })
  end

  return workspaces
end

-- Validate workspace path exists
local function validate_workspace_path(path)
  local expanded = expand_path(path)
  local stat = vim.loop.fs_stat(expanded)

  if not stat then
    return false, "Path does not exist: " .. expanded
  end

  if stat.type ~= "directory" then
    return false, "Path is not a directory: " .. expanded
  end

  return true, expanded
end

-- Set active workspace (cd to directory, save state)
function M.set_workspace(workspace_name)
  if not M.is_enabled() then
    vim.notify("Workspace management is disabled", vim.log.levels.WARN)
    return false
  end

  local workspace = config.workspace_management.workspaces and config.workspace_management.workspaces[workspace_name]

  if not workspace then
    vim.notify("Workspace '" .. workspace_name .. "' not found", vim.log.levels.ERROR)
    return false
  end

  -- Validate path exists
  local valid, result = validate_workspace_path(workspace.path)
  if not valid then
    vim.notify("Cannot switch to workspace: " .. result, vim.log.levels.ERROR)
    return false
  end

  local path = result

  -- Change directory
  local ok, err = pcall(vim.fn.chdir, path)
  if not ok then
    vim.notify("Failed to change directory: " .. err, vim.log.levels.ERROR)
    return false
  end

  -- Update active workspace in config
  config.workspace_management.active_workspace = workspace_name

  -- Save state
  M.save_workspace_state()

  -- Notify user
  local display_name = workspace.name or workspace_name
  vim.notify("Switched to workspace: " .. display_name .. "\nPath: " .. path, vim.log.levels.INFO)

  return true
end

-- Save workspace state to JSON file
function M.save_workspace_state()
  if not M.is_enabled() then
    return
  end

  local state_file = config.workspace_management.state_file
  local state = {
    active_workspace = config.workspace_management.active_workspace,
    last_updated = os.time(),
  }

  -- Ensure directory exists
  local state_dir = vim.fn.fnamemodify(state_file, ":h")
  vim.fn.mkdir(state_dir, "p")

  -- Write state
  local ok, err = pcall(vim.fn.writefile, vim.split(vim.fn.json_encode(state), "\n", true), state_file)
  if not ok then
    vim.notify("Failed to save workspace state: " .. err, vim.log.levels.WARN)
  end
end

-- Load workspace state from JSON file
function M.get_workspace_state()
  if not M.is_enabled() then
    return nil
  end

  local state_file = config.workspace_management.state_file

  -- Check if file exists
  local stat = vim.loop.fs_stat(state_file)
  if not stat then
    return nil
  end

  -- Read file
  local ok, lines = pcall(vim.fn.readfile, state_file)
  if not ok then
    return nil
  end

  local content = table.concat(lines, "\n")
  local ok2, state = pcall(vim.fn.json_decode, content)
  if not ok2 then
    return nil
  end

  return state
end

-- Initialize workspace on startup (restore last workspace)
function M.init()
  if not M.is_enabled() then
    return
  end

  -- Load saved state
  local state = M.get_workspace_state()
  if state and state.active_workspace then
    local active = state.active_workspace

    -- Check if workspace still exists in config
    if config.workspace_management.workspaces and config.workspace_management.workspaces[active] then
      config.workspace_management.active_workspace = active

      -- Change to workspace directory
      local workspace = config.workspace_management.workspaces[active]
      local valid, result = validate_workspace_path(workspace.path)
      if valid then
        vim.fn.chdir(result)
        vim.notify("Restored workspace: " .. (workspace.name or active), vim.log.levels.INFO)
      end
    end
  end
end

return M
