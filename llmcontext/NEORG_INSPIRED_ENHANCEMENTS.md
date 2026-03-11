# Neorg-Inspired Enhancements Plan

**Branch:** feature/neorg-enhancements  
**Status:** Planning Phase  
**Created:** 2025-12-30  
**Priority:** Moderate Breaking Changes Allowed  

---

## Executive Summary

This document outlines a comprehensive enhancement plan to integrate Neorg's best features into our existing Markdown-based note-taking setup while maintaining universal format compatibility and portability.

### Philosophy

- **Keep Markdown:** Maintain `.md` format for universal compatibility
- **Enhance, Don't Replace:** Add powerful features without breaking existing workflows
- **Modular Design:** Each enhancement is independently toggleable
- **Future-Proof:** Design for multi-workspace, multi-platform usage

### Key Enhancements Overview

1. **Phase 0:** Path Refactoring & Modular Split (Foundation)
2. **Phase 11:** Multi-State Checkbox System (HIGH Priority)
3. **Phase 12:** Workspace Management (HIGH Priority)
4. **Phase 13:** Time Tracking Enhancement (MEDIUM Priority)
5. **Phase 14:** Export System (MEDIUM Priority)
6. **Phase 15:** Advanced Text Objects (LOW Priority)
7. **Phase 16:** Enhanced Analytics (LOW Priority)

### Estimated Impact

- **New Code:** ~1,400 lines across 7 new modules
- **Modified Code:** ~200 lines in existing files
- **New Files:** 8 Lua modules + 3 templates
- **Breaking Changes:** Minimal (migration commands provided)
- **Implementation Time:** 3-6 sessions

---

## Current State Analysis

### Existing Setup Strengths

✅ Comprehensive markdown enhancement (1,230 lines)  
✅ YAML frontmatter with auto-update  
✅ Date-based file naming  
✅ Mac Reminders integration  
✅ Pomodoro timer integration  
✅ Backlinks system  
✅ Full-text search  
✅ Checkbox management  
✅ Folding support  
✅ Image paste functionality  

### Current Limitations

❌ Binary checkbox states only (`[ ]` / `[x]`)  
❌ Single workspace (hardcoded OneDrive path)  
❌ No time tracking logs or reports  
❌ No export functionality  
❌ No advanced text objects  
❌ No analytics or statistics  
❌ Large monolithic file (hard to maintain)  

### Hardcoded Paths Found

**File:** `lua/plugins/notes_profile/markdown-enhancements.lua`

- Line 555: `collect_notes_metadata()`
- Line 973: Backlink insertion
- Line 982: Telescope workspace path
- Line 1021: Full-text search

**Action Required:** Extract to shared config module (Phase 0)

---

## Phase 0: Path Refactoring & Modular Split

**Priority:** MUST DO FIRST (Foundation)  
**Complexity:** Low  
**Risk:** Low  
**Estimated Lines:** ~300 (refactoring + new config)  

### Objective

Refactor the monolithic `markdown-enhancements.lua` (1,230 lines) into modular components and extract hardcoded paths to a shared configuration module. This creates a clean foundation for all future enhancements.

### Current Structure Problems

1. **Hardcoded Paths:** 4 instances of OneDrive path scattered throughout
2. **Single Large File:** 1,230 lines in one file (hard to navigate)
3. **Mixed Concerns:** Config, functions, keymaps, autocmds all together
4. **No Shared Config:** Each function re-expands paths

### Target Modular Structure

```
lua/plugins/notes_profile/
├── config.lua                    (NEW - 50 lines)
│   └── Shared configuration (paths, settings, constants)
│
├── markdown-enhancements.lua     (REFACTORED - 400 lines)
│   └── Core markdown features, formatting, folding
│
├── checkbox-core.lua             (NEW - 150 lines)
│   └── Existing checkbox functions (extracted from main file)
│
├── yaml-manager.lua              (NEW - 250 lines)
│   └── YAML parsing, metadata, frontmatter functions
│
├── navigation.lua                (NEW - 150 lines)
│   └── Backlinks, heading search, TOC generation
│
├── reminders.lua                 (NEW - 200 lines)
│   └── Mac Reminders integration
│
└── pomodoro-integration.lua      (NEW - 150 lines)
    └── Pomodoro timer integration
```

**Total After Split:** 1,350 lines (120 lines added for module structure)

### New Config Module Design

**File:** `lua/plugins/notes_profile/config.lua`

```lua
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
  { symbol = " ", label = "Pending",     icon = "○", next = "-" },
  { symbol = "-", label = "In Progress", icon = "◐", next = "x" },
  { symbol = "x", label = "Done",        icon = "✓", next = "_" },
  { symbol = "_", label = "Cancelled",   icon = "✗", next = " " },
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
  multi_state_checkboxes = true,
  workspace_management = true,
  time_tracking = true,
  export_system = true,
  text_objects = true,
  analytics = true,
}

function M.is_enabled(feature)
  return M.features[feature] == true
end

return M
```

### Migration Strategy

**Step 1:** Create `config.lua` module  
**Step 2:** Extract checkbox functions to `checkbox-core.lua`  
**Step 3:** Extract YAML functions to `yaml-manager.lua`  
**Step 4:** Extract navigation functions to `navigation.lua`  
**Step 5:** Extract reminders to `reminders.lua`  
**Step 6:** Extract Pomodoro to `pomodoro-integration.lua`  
**Step 7:** Update `markdown-enhancements.lua` to require all modules  
**Step 8:** Test all existing functionality  

### Updated File Sizes After Refactor

| File | Lines | Purpose |
|------|-------|---------|
| `config.lua` | 150 | Shared config, paths, constants |
| `markdown-enhancements.lua` | 400 | Core markdown features, entry point |
| `checkbox-core.lua` | 150 | Checkbox toggle, move, insert |
| `yaml-manager.lua` | 250 | YAML parsing, metadata, auto-update |
| `navigation.lua` | 150 | Backlinks, headings, TOC, search |
| `reminders.lua` | 200 | Mac Reminders integration |
| `pomodoro-integration.lua` | 150 | Timer integration |
| **Total** | **1,450** | **(was 1,230, +220 for structure)** |

### Testing Checklist

- [ ] All existing keybindings work
- [ ] YAML auto-update on save works
- [ ] Checkbox toggle works
- [ ] Mac Reminders sync works
- [ ] Pomodoro integration works
- [ ] Backlinks insertion works
- [ ] Full-text search works
- [ ] Metadata search works
- [ ] Folding works
- [ ] No Lua errors on startup

### Rollback Procedure

1. Keep original `markdown-enhancements.lua` as `markdown-enhancements.lua.backup`
2. If issues occur, restore backup and remove new module files
3. Restart Neovim

### Success Criteria

✅ All modules load without errors  
✅ All existing features work identically  
✅ Paths are configurable via `config.lua`  
✅ Code is more maintainable  
✅ Foundation ready for Phase 11+  

---

## Phase 11: Multi-State Checkbox System

**Priority:** HIGH  
**Complexity:** Medium  
**Risk:** Medium (modifies core checkbox function)  
**Estimated Lines:** 200 (new checkbox-manager.lua)  

### Objective

Extend checkbox functionality beyond binary done/undone states to support workflow tracking with four states: Pending, In Progress, Done, and Cancelled.

### Current Limitation

Currently checkboxes only support two states:
- `- [ ]` Unchecked
- `- [x]` Checked

### Target Multi-State System (Option A - Minimal)

```markdown
- [ ] Pending - Not started yet
- [-] In Progress - Currently working on
- [x] Done - Completed successfully
- [_] Cancelled - Decided not to do
```

### Visual Rendering (with concealer)

When rendered in Neovim:
- `[ ]` → `○ Pending`
- `[-]` → `◐ In Progress`
- `[x]` → `✓ Done`
- `[_]` → `✗ Cancelled`

### Implementation Details

**File:** `lua/plugins/notes_profile/checkbox-manager.lua` (NEW)

This new module will:
1. Replace the existing `toggle_checkbox()` function
2. Add state cycling logic
3. Add state filtering for Trouble.nvim
4. Add statistics counting
5. Provide migration command for existing checkboxes

### Key Functions

```lua
-- Cycle checkbox state forward
function M.cycle_checkbox_forward()
  -- [ ] → [-] → [x] → [_] → [ ]
end

-- Cycle checkbox state backward
function M.cycle_checkbox_backward()
  -- [ ] → [_] → [x] → [-] → [ ]
end

-- Get checkbox state from line
function M.get_checkbox_state(line)
  -- Returns: {symbol, label, icon, next}
end

-- Count checkboxes by state in buffer
function M.count_checkbox_states()
  -- Returns: {pending=5, in_progress=2, done=10, cancelled=3}
end

-- Filter checkboxes by state (for Trouble.nvim)
function M.filter_by_state(state)
  -- Returns list of line numbers matching state
end

-- Migrate old checkboxes to new format
function M.migrate_checkbox_format()
  -- Scans all [ ] and [x] checkboxes
  -- Prompts user for confirmation
  -- Converts to new format
end
```

### Integration with Existing Features

**1. Move to DONE Section**
- Update `move_checked_to_done()` to handle all completion states
- Both `[x]` Done and `[_]` Cancelled should move to DONE
- Keep state symbol when moving

**2. Mac Reminders Integration**
- Only sync `[ ]` Pending and `[-]` In Progress to Mac Reminders
- Mark as complete in Mac when state becomes `[x]` Done
- Delete from Mac when state becomes `[_]` Cancelled

**3. Folding Display**
- Update fold text to show state icon instead of just ✓
- Example: `○ Write documentation [5 lines]`

**4. Trouble.nvim Integration**
- Add filters: `:TodoTrouble pending`, `:TodoTrouble in_progress`
- Show state in Trouble list

**5. Statistics Display**
- New command to show checkbox distribution
- Visual progress bar for completion rate

### New Keybindings

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>cx` | Cycle Forward | `[ ]` → `[-]` → `[x]` → `[_]` → `[ ]` |
| `<leader>cX` | Cycle Backward | Reverse cycle |
| `<leader>cs` | Show Statistics | Display checkbox state counts |
| `<leader>cp` | Set Pending | Force set to `[ ]` |
| `<leader>ci` | Set In Progress | Force set to `[-]` |
| `<leader>cd` | Set Done | Force set to `[x]` |
| `<leader>cc` | Set Cancelled | Force set to `[_]` |
| `<leader>cM` | Migrate Format | Migrate old checkboxes |

### Migration Command

When user runs `<leader>cM`:

```
Found 47 checkboxes in vault:
  - 23 old format [ ]
  - 15 old format [x]
  - 9 already migrated

Migrate to new format? (y/n)
> y

Migrating...
  ✓ 2024-12-01-meeting-notes.md (5 checkboxes)
  ✓ 2024-12-15-project-plan.md (12 checkboxes)
  ...

Migration complete! 38 checkboxes updated.
```

### Backward Compatibility

**Option C - Manual Migration:**
- Existing `[ ]` and `[x]` checkboxes continue to work
- New checkboxes use full state system
- Migration command available but optional
- No automatic scanning/conversion

### Statistics Display Example

When user runs `<leader>cs`:

```
╭─────────────────────────────────╮
│ Checkbox Statistics             │
├─────────────────────────────────┤
│ ○ Pending:      12 (24%)       │
│ ◐ In Progress:   5 (10%)       │
│ ✓ Done:         28 (56%)       │
│ ✗ Cancelled:     5 (10%)       │
├─────────────────────────────────┤
│ Total:          50              │
│ Completion:     56%             │
│ Progress Bar:   ████████░░      │
╰─────────────────────────────────╯
```

### File Structure Changes

```diff
lua/plugins/notes_profile/
├── config.lua (updated: add checkbox_states config)
+├── checkbox-manager.lua (NEW - 200 lines)
│   ├── cycle_checkbox_forward()
│   ├── cycle_checkbox_backward()
│   ├── get_checkbox_state()
│   ├── count_checkbox_states()
│   ├── show_statistics()
│   ├── filter_by_state()
│   └── migrate_checkbox_format()
├── checkbox-core.lua (refactored: extract from main file)
└── markdown-enhancements.lua (updated: require checkbox-manager)
```

### Testing Checklist

- [ ] Cycle forward through all 4 states
- [ ] Cycle backward through all 4 states
- [ ] Direct state set commands work
- [ ] Statistics display accurate counts
- [ ] Folding shows correct state icon
- [ ] Move to DONE handles all completion states
- [ ] Mac Reminders only sync pending/in-progress
- [ ] Mac Reminders complete when state = done
- [ ] Mac Reminders delete when state = cancelled
- [ ] Migration command works correctly
- [ ] Trouble.nvim filters by state
- [ ] No regression in existing checkbox features

### Rollback Procedure

1. Remove `checkbox-manager.lua`
2. Restore original `toggle_checkbox()` in `checkbox-core.lua`
3. Remove new keybindings
4. Checkboxes revert to binary `[ ]` / `[x]` behavior

### Success Criteria

✅ Can cycle through 4 states smoothly  
✅ State persists correctly in file  
✅ Statistics display accurate  
✅ Integration with Mac Reminders works  
✅ Migration command available  
✅ No regression in existing features  

---

## Phase 12: Workspace Management System

**Priority:** HIGH  
**Complexity:** Medium  
**Risk:** Low (new module, minimal modifications)  
**Estimated Lines:** 150 (new workspace-manager.lua)  

### Objective

Enable quick switching between multiple note directories/vaults while maintaining workspace-specific context and settings.

### Current Limitation

All paths hardcoded to single OneDrive location:
```lua
"~/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault"
```

### Target Multi-Workspace System

Support multiple workspaces with persistent active workspace tracking:

```lua
workspaces = {
  work = "~/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault",
  test = "/tmp/neorg-test-vault",
  personal = "~/notes/personal",  -- Future
  archive = "~/notes/archive",     -- Future
}
```

### Workspace Features

1. **Quick Switching:** Change workspace with 2 keystrokes
2. **Persistent State:** Remember active workspace across Neovim restarts
3. **Isolated Context:** Each workspace is independent
4. **Status Indicator:** Show active workspace in status line
5. **Auto-Create:** Automatically create workspace directories if missing

### Implementation Details

**File:** `lua/plugins/notes_profile/workspace-manager.lua` (NEW)

### Key Functions

```lua
-- Switch to a different workspace
function M.switch_workspace(workspace_name)
  -- Validates workspace exists
  -- Updates active workspace
  -- Saves to state file
  -- Broadcasts workspace change event
  -- Updates status line
end

-- List all workspaces with Telescope picker
function M.workspace_picker()
  -- Shows workspace list with:
  --   - Name
  --   - Path
  --   - Note count
  --   - Active indicator (*)
end

-- Get current workspace info
function M.get_current_info()
  -- Returns: {name, path, note_count, active}
end

-- Create new workspace
function M.create_workspace(name, path)
  -- Adds to config
  -- Creates directory if needed
  -- Saves config
end

-- Validate workspace (check if directory exists and is accessible)
function M.validate_workspace(name)
  -- Returns: {valid, error_message}
end
```

### Workspace Picker UI (Telescope)

When user presses `<leader>ws`:

```
┌─ Select Workspace ──────────────────────────────────────┐
│ > work                                                  │
│   * ~/Library/.../notevault (142 notes)                 │
│                                                         │
│   test                                                  │
│     /tmp/neorg-test-vault (3 notes)                     │
│                                                         │
│   personal                                              │
│     ~/notes/personal (not created)                      │
│                                                         │
│   archive                                               │
│     ~/notes/archive (87 notes)                          │
└─────────────────────────────────────────────────────────┘
```

### Integration with Existing Features

All path-dependent functions will be updated to use active workspace:

**1. Metadata Search (`<leader>ys`)**
```lua
-- Before:
local notes_dir = "~/Library/.../notevault"

-- After:
local notes_dir = require("plugins.notes_profile.config").get_workspace_path()
```

**2. Backlinks (`<leader>bl`)**
```lua
-- Before:
cwd = vim.fn.expand("~/Library/.../notevault")

-- After:
cwd = require("plugins.notes_profile.config").get_workspace_path()
```

**3. Full-Text Search (`<leader>fn`)**
```lua
-- Before:
cwd = vim.fn.expand("~/Library/.../notevault")

-- After:
cwd = require("plugins.notes_profile.config").get_workspace_path()
```

**4. Mac Reminders Body**
```lua
-- Before:
local filename = vim.fn.expand("%:t:r")

-- After:
local workspace = require("plugins.notes_profile.config").get_active_workspace()
local filename = vim.fn.expand("%:t:r")
local body = string.format("From: %s/%s (line %d)", workspace, filename, lnum)
```

### Status Line Integration

Add workspace indicator to status line (if using lualine):

```lua
-- In lualine config
sections = {
  lualine_x = {
    function()
      local config = require("plugins.notes_profile.config")
      if vim.bo.filetype == "markdown" then
        return "📁 " .. config.get_active_workspace()
      end
      return ""
    end,
    'encoding',
    'fileformat',
    'filetype'
  },
}
```

Result in status line:
```
📁 work | utf-8 | unix | markdown
```

### New Keybindings

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>ws` | Switch Workspace | Open Telescope picker to switch |
| `<leader>wl` | List Workspaces | Show all workspaces with info |
| `<leader>wc` | Current Workspace | Show current workspace details |
| `<leader>wn` | New Workspace | Create a new workspace |
| `<leader>wv` | Validate Workspace | Check if workspace is accessible |

### Workspace Commands

```vim
:NorgWorkspaceSwitch <name>  " Switch to workspace
:NorgWorkspaceList           " List all workspaces
:NorgWorkspaceCurrent        " Show current workspace
:NorgWorkspaceNew            " Create new workspace
:NorgWorkspaceValidate       " Validate all workspaces
```

### Persistence Implementation

**State File:** `~/.local/state/nvim/notes_profile/workspace.txt`

**Content:**
```
work
```

**Loading on Startup:**
1. Check if state file exists
2. Read workspace name
3. Validate workspace exists
4. Set as active workspace
5. If invalid, fall back to default

### Auto-Create Test Workspace

On first load, automatically create test workspace:

```lua
function M.ensure_test_workspace()
  local test_path = "/tmp/neorg-test-vault"
  if vim.fn.isdirectory(test_path) == 0 then
    vim.fn.mkdir(test_path, "p")
    
    -- Create sample test note
    local sample = test_path .. "/test-note.md"
    local content = [[
---
title: Test Note
created: ]] .. os.date("%Y-%m-%d %H:%M:%S") .. [[

updated: ]] .. os.date("%Y-%m-%d %H:%M:%S") .. [[

status: draft
tags:
  - test
---

# Test Note

This is a test note for the new workspace system.

## Checkboxes
- [ ] Test pending
- [-] Test in progress
- [x] Test done
- [_] Test cancelled
]]
    
    local file = io.open(sample, "w")
    if file then
      file:write(content)
      file:close()
    end
  end
end
```

### File Structure Changes

```diff
lua/plugins/notes_profile/
├── config.lua (updated: add workspace functions)
+├── workspace-manager.lua (NEW - 150 lines)
│   ├── switch_workspace()
│   ├── workspace_picker()
│   ├── get_current_info()
│   ├── create_workspace()
│   ├── validate_workspace()
│   └── ensure_test_workspace()
├── yaml-manager.lua (updated: use get_workspace_path())
├── navigation.lua (updated: use get_workspace_path())
├── reminders.lua (updated: include workspace in reminder body)
└── markdown-enhancements.lua (updated: workspace indicator)
```

### Testing Checklist

- [ ] Can switch between workspaces
- [ ] Active workspace persists across Neovim restart
- [ ] Metadata search respects active workspace
- [ ] Backlinks search respects active workspace
- [ ] Full-text search respects active workspace
- [ ] Status line shows correct workspace
- [ ] Test workspace auto-created on first load
- [ ] Telescope picker shows correct info
- [ ] Invalid workspace falls back to default
- [ ] Can create new workspace via command
- [ ] Workspace validation works

### Rollback Procedure

1. Remove `workspace-manager.lua`
2. Revert path changes in other modules (use hardcoded paths)
3. Remove workspace keybindings
4. Remove status line integration
5. System reverts to single workspace

### Success Criteria

✅ Can switch workspaces in <2 seconds  
✅ Active workspace persists across sessions  
✅ All search functions respect workspace  
✅ Status line shows workspace indicator  
✅ Test workspace auto-created  
✅ No performance degradation  
✅ Backward compatible (single workspace still works)  

---

## Phase 13: Time Tracking Enhancement

**Priority:** MEDIUM  
**Complexity:** Medium  
**Risk:** Medium (modifies Pomodoro integration)  
**Estimated Lines:** 250 (new time-tracker.lua)  

### Objective

Implement intermediate time tracking with automatic logging, task-based reporting, and dual storage (in-file YAML + centralized JSON database).

### Current Limitation

Pomodoro integration only:
- Starts timers on checkbox lines
- Plays completion sounds
- Manual session markers (`| [*]`, `| [**]`)
- No automatic logging
- No time reports

### Target Time Tracking System

**Dual Storage Approach:**
1. **In-File (YAML):** Portable, human-readable, travels with note
2. **Database (JSON):** Fast queries, aggregation, reports

**Storage by Period:** 
- Monthly JSON files: `2025-12.json`, `2026-01.json`
- Keeps files small and manageable
- Easy to archive old periods

### YAML Frontmatter Structure

```yaml
---
title: Project Planning
created: 2025-12-30 10:00:00
updated: 2025-12-30 16:00:00
tags:
  - project
  - planning
time_logs:
  - task: "Write project requirements"
    start: "2025-12-30 14:00:00"
    end: "2025-12-30 14:25:00"
    duration: 25
    type: "work"
    workspace: "work"
  - task: "Review architecture design"
    start: "2025-12-30 15:00:00"
    end: "2025-12-30 15:25:00"
    duration: 25
    type: "work"
    workspace: "work"
---
```

### JSON Database Structure

**File:** `~/.local/share/nvim/notes_profile/time_logs/2025-12.json`

```json
{
  "period": "2025-12",
  "logs": [
    {
      "timestamp": "2025-12-30T14:00:00",
      "file": "2025-12-28-project-planning.md",
      "workspace": "work",
      "task": "Write project requirements",
      "start": "2025-12-30 14:00:00",
      "end": "2025-12-30 14:25:00",
      "duration": 25,
      "type": "work",
      "tags": ["project", "planning"]
    },
    {
      "timestamp": "2025-12-30T15:00:00",
      "file": "2025-12-28-project-planning.md",
      "workspace": "work",
      "task": "Review architecture design",
      "start": "2025-12-30 15:00:00",
      "end": "2025-12-30 15:25:00",
      "duration": 25,
      "type": "work",
      "tags": ["project", "planning"]
    }
  ],
  "summary": {
    "total_sessions": 2,
    "total_minutes": 50,
    "by_type": {
      "work": 50,
      "rest": 0
    },
    "by_workspace": {
      "work": 50
    }
  }
}
```

### Implementation Details

**File:** `lua/plugins/notes_profile/time-tracker.lua` (NEW)

### Key Functions

```lua
-- Auto-log time when Pomodoro completes
function M.on_timer_complete(task, duration, timer_type)
  -- 1. Extract task info from checkbox line
  -- 2. Append to YAML frontmatter (time_logs)
  -- 3. Append to JSON database (current period)
  -- 4. Update summary statistics
end

-- Generate daily time report
function M.show_daily_report(date)
  -- date: "2025-12-30" or nil (today)
  -- Queries JSON database for day's logs
  -- Shows: total time, by task, by file, by tag
end

-- Generate weekly time report
function M.show_weekly_report(week)
  -- week: "2025-W52" or nil (current week)
  -- Aggregates across days
  -- Shows: total time, trends, top tasks
end

-- Show task-specific time log
function M.show_task_log(task_pattern)
  -- Search across all periods
  -- Shows all sessions matching pattern
  -- Total time spent on task
end

-- Query time logs
function M.query_logs(filters)
  -- filters: {date, workspace, tag, file, type}
  -- Returns matching logs
end

-- Export time logs (CSV, for external tools)
function M.export_logs(period, format)
  -- period: "2025-12" or "2025-W52"
  -- format: "csv", "json"
end
```

### Enhanced Pomodoro Integration

**Update existing Pomodoro keybindings:**

```lua
-- <leader>tp - Start Pomodoro (ENHANCED)
vim.keymap.set("n", "<leader>tp", function()
  local line = vim.api.nvim_get_current_line()
  if line:match("^%s*- %[.%] ") then
    local task = line:match("^%s*- %[.%] (.*)")
    -- Remove @remind() annotation if present
    task = task:gsub("%s*@remind%([^%)]+%)", "")
    
    local short = task:sub(1, 30) -- Use first 30 chars as title
    
    -- Start timer
    vim.cmd("TimerStart 25m " .. vim.fn.shellescape(short))
    
    -- Register callback for completion
    local timer_tracker = require("plugins.notes_profile.time-tracker")
    timer_tracker.register_timer(task, 25, "work")
    
    vim.notify("Started 25m Pomodoro: " .. short, vim.log.levels.INFO)
  end
end, { buffer = true, desc = "Start Pomodoro on Checkbox (with logging)" })
```

### Time Reports UI (Telescope)

**Daily Report** (`<leader>td`):

```
┌─ Daily Time Report: 2025-12-30 ─────────────────────────┐
│                                                          │
│ Total Time: 3h 45m (9 sessions)                        │
│                                                          │
│ By Task:                                                 │
│   Write project requirements          50m (2 sessions) │
│   Review architecture design          50m (2 sessions) │
│   Code implementation                 75m (3 sessions) │
│   Team meeting                        50m (2 sessions) │
│                                                          │
│ By File:                                                 │
│   2025-12-28-project-planning.md      100m            │
│   2025-12-29-implementation.md         75m            │
│   2025-12-30-meeting-notes.md          50m            │
│                                                          │
│ By Tag:                                                  │
│   #project                            175m            │
│   #meeting                             50m            │
│                                                          │
│ Time Distribution:                                       │
│ ████████████████░░░░░░░░                                │
│ 08:00   10:00   12:00   14:00   16:00   18:00         │
└──────────────────────────────────────────────────────────┘
```

**Weekly Report** (`<leader>tw`):

```
┌─ Weekly Time Report: 2025-W52 ──────────────────────────┐
│                                                          │
│ Week: Dec 23 - Dec 29, 2025                            │
│ Total Time: 18h 45m (45 sessions)                      │
│ Average: 2h 40m per day                                │
│                                                          │
│ Daily Breakdown:                                         │
│   Mon (23) ████████████░░░░░ 3h 15m (8 sessions)      │
│   Tue (24) ████████████████░ 4h 00m (10 sessions)     │
│   Wed (25) ██████░░░░░░░░░░░ 1h 30m (3 sessions)      │
│   Thu (26) ████████████████░ 4h 00m (10 sessions)     │
│   Fri (27) ██████████████░░░ 3h 30m (9 sessions)      │
│   Sat (28) ████░░░░░░░░░░░░░ 1h 00m (2 sessions)      │
│   Sun (29) ██████░░░░░░░░░░░ 1h 30m (3 sessions)      │
│                                                          │
│ Top Tasks:                                               │
│   1. Code implementation              5h 15m           │
│   2. Documentation writing            4h 30m           │
│   3. Code review                      3h 45m           │
│   4. Meetings                         3h 00m           │
│   5. Planning                         2h 15m           │
│                                                          │
│ Productivity Trend: ↗ +15% from last week             │
└──────────────────────────────────────────────────────────┘
```

### New Keybindings

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>td` | Daily Report | Show today's time tracking |
| `<leader>tw` | Weekly Report | Show current week's tracking |
| `<leader>tm` | Monthly Report | Show current month's tracking |
| `<leader>tt` | Task Log | Search time logs by task |
| `<leader>tq` | Query Logs | Custom query with filters |
| `<leader>te` | Export Logs | Export to CSV/JSON |

### Auto-Logging on Timer Completion

```lua
-- When Pomodoro timer completes
vim.api.nvim_create_autocmd("User", {
  pattern = "TimerComplete",
  callback = function(args)
    local timer_data = args.data
    
    -- Get task from registered timers
    local tracker = require("plugins.notes_profile.time-tracker")
    local task_info = tracker.get_registered_timer(timer_data.id)
    
    if task_info then
      -- Log to YAML frontmatter
      tracker.log_to_yaml(task_info)
      
      -- Log to JSON database
      tracker.log_to_database(task_info)
      
      vim.notify("Time logged: " .. task_info.task .. " (" .. task_info.duration .. "m)", vim.log.levels.INFO)
    end
  end,
})
```

### File Structure Changes

```diff
lua/plugins/notes_profile/
├── config.lua (updated: add time_db functions)
+├── time-tracker.lua (NEW - 250 lines)
│   ├── on_timer_complete()
│   ├── log_to_yaml()
│   ├── log_to_database()
│   ├── show_daily_report()
│   ├── show_weekly_report()
│   ├── show_monthly_report()
│   ├── show_task_log()
│   ├── query_logs()
│   └── export_logs()
├── pomodoro-integration.lua (updated: register timers)
└── yaml-manager.lua (updated: handle time_logs field)
```

### Database Management

**Auto-cleanup:**
- Keep last 12 months of JSON files
- Archive older files to `time_logs/archive/`
- Provide command to clean up: `:NorgTimeCleanup`

**Database Integrity:**
- Validate JSON on load
- Auto-repair if corrupted
- Backup before major operations

### Testing Checklist

- [ ] Pomodoro completion auto-logs time
- [ ] Time appears in YAML frontmatter
- [ ] Time appears in JSON database
- [ ] Daily report shows accurate totals
- [ ] Weekly report aggregates correctly
- [ ] Monthly report works
- [ ] Task log search finds correct sessions
- [ ] Can filter by workspace
- [ ] Can filter by tag
- [ ] Can export to CSV
- [ ] Database creates monthly files correctly
- [ ] Old databases get archived
- [ ] Reports load in <1 second
- [ ] No performance impact on note saving

### Rollback Procedure

1. Remove `time-tracker.lua`
2. Revert Pomodoro integration changes
3. Remove time tracking keybindings
4. Time logs in YAML stay but are ignored
5. JSON database remains but unused
6. System reverts to simple Pomodoro timers

### Success Criteria

✅ Time logs automatically saved on completion  
✅ Daily report shows accurate totals  
✅ Weekly report aggregates correctly  
✅ Can filter by task/tag/workspace  
✅ Reports generate in <1 second  
✅ Dual storage (YAML + JSON) works  
✅ Database splits by month correctly  
✅ No impact on note editing performance  

---

## Phase 14: Export System

**Priority:** MEDIUM  
**Complexity:** High (external dependencies)  
**Risk:** Low (new module, no modifications)  
**Estimated Lines:** 300 (export.lua + templates)  

### Objective

Export markdown notes to HTML (with custom CSS), PDF (via pandoc), and presentation slides (reveal.js) while preserving formatting, YAML metadata, and code highlighting.

### Export Formats Priority

1. **HTML** (HIGH) - Self-contained, custom CSS, no external deps
2. **PDF** (MEDIUM) - Via pandoc (requires installation)
3. **Presentation** (LOW) - reveal.js slides, nice-to-have

### Implementation Details

**File:** `lua/plugins/notes_profile/export.lua` (NEW)

### Key Functions

```lua
-- Export to HTML
function M.export_to_html(template)
  -- template: "minimal", "professional", or custom path
  -- Converts markdown to HTML
  -- Applies CSS template
  -- Embeds code highlighting
  -- Preserves YAML as header
  -- Returns: output file path
end

-- Export to PDF (requires pandoc)
function M.export_to_pdf(template)
  -- template: "minimal", "professional"
  -- Checks for pandoc installation
  -- Converts via pandoc
  -- Returns: output file path
end

-- Export to presentation (reveal.js)
function M.export_to_presentation()
  -- Splits on --- (slide breaks)
  -- Generates reveal.js HTML
  -- Returns: output file path
end

-- Export picker (Telescope)
function M.export_picker()
  -- Shows format options
  -- Shows template options
  -- Previews export settings
end

-- Check dependencies
function M.check_dependencies()
  -- Returns: {pandoc_installed, version}
end
```

### HTML Templates

**Template Directory:** `lua/plugins/notes_profile/templates/`

**Minimal Template** (`html-minimal.html`):
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{TITLE}}</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      max-width: 800px;
      margin: 40px auto;
      padding: 0 20px;
      line-height: 1.6;
      color: #333;
    }
    .metadata {
      background: #f5f5f5;
      padding: 20px;
      border-radius: 8px;
      margin-bottom: 30px;
    }
    code {
      background: #f0f0f0;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Monaco', 'Courier New', monospace;
    }
    pre {
      background: #f8f8f8;
      padding: 15px;
      border-radius: 5px;
      overflow-x: auto;
    }
    h1 { color: #2c3e50; }
    h2 { color: #34495e; border-bottom: 2px solid #ecf0f1; padding-bottom: 5px; }
    a { color: #3498db; text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <div class="metadata">
    {{METADATA}}
  </div>
  <article>
    {{CONTENT}}
  </article>
</body>
</html>
```

**Professional Template** (`html-professional.html`):
- More sophisticated styling
- Table of contents sidebar
- Syntax highlighting for code
- Print-friendly CSS
- Dark mode support

### Export Flow

1. **Parse Markdown:**
   - Extract YAML frontmatter
   - Convert markdown body to HTML
   - Process code blocks with syntax highlighting
   - Convert checkboxes to styled HTML elements

2. **Apply Template:**
   - Inject metadata into template
   - Inject content into template
   - Apply CSS styling
   - Embed fonts/assets (for self-contained HTML)

3. **Save Output:**
   - Save to same directory as source
   - Filename: `{original-name}.html` or `{original-name}.pdf`
   - Open in browser (optional)

### Checkbox Rendering in HTML

```html
<!-- Pending -->
<input type="checkbox" disabled> Pending task

<!-- In Progress -->
<input type="checkbox" class="in-progress" disabled> In progress task

<!-- Done -->
<input type="checkbox" checked disabled> Done task

<!-- Cancelled -->
<input type="checkbox" class="cancelled" disabled> Cancelled task
```

With CSS:
```css
input[type="checkbox"].in-progress::before {
  content: "◐";
  color: #f39c12;
}
input[type="checkbox"].cancelled {
  opacity: 0.5;
  text-decoration: line-through;
}
```

### Code Highlighting

Use built-in Neovim treesitter for syntax highlighting:

```lua
function M.highlight_code_block(code, language)
  -- Use treesitter to parse code
  -- Generate HTML with span tags for colors
  -- Apply GitHub-style color scheme
  -- Returns: highlighted HTML
end
```

### PDF Export (via pandoc)

**Requirements Check:**
```lua
function M.check_pandoc()
  local handle = io.popen("pandoc --version")
  local result = handle:read("*a")
  handle:close()
  
  if result:match("pandoc") then
    local version = result:match("pandoc (%d+%.%d+)")
    return true, version
  else
    return false, nil
  end
end
```

**PDF Export Command:**
```bash
pandoc input.md \
  --from=markdown \
  --to=pdf \
  --pdf-engine=xelatex \
  --template=professional.tex \
  --metadata-file=metadata.yaml \
  --highlight-style=tango \
  --output=output.pdf
```

### Export Picker UI (Telescope)

When user presses `<leader>ee`:

```
┌─ Export Document ────────────────────────────────────────┐
│ > HTML (Minimal)                                         │
│   HTML (Professional)                                    │
│   PDF (Minimal) [requires pandoc]                       │
│   PDF (Professional) [requires pandoc]                  │
│   Presentation (reveal.js)                               │
│   Custom HTML Template...                                │
│                                                          │
│ Preview:                                                 │
│   Format: HTML                                          │
│   Template: Minimal                                     │
│   Output: 2025-12-30-project-plan.html                 │
│   Size: ~125KB (estimated)                             │
└──────────────────────────────────────────────────────────┘
```

### New Keybindings

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>eh` | Export HTML | Quick export to HTML (minimal) |
| `<leader>ep` | Export PDF | Quick export to PDF (requires pandoc) |
| `<leader>es` | Export Slides | Export to reveal.js presentation |
| `<leader>ee` | Export Picker | Choose format and template |
| `<leader>eo` | Open Export | Open last exported file |
| `<leader>ec` | Check Deps | Check for pandoc and other tools |

### Template Customization

Users can create custom templates in:
```
~/.config/nvim/lua/plugins/notes_profile/templates/custom/
```

Templates can use these placeholders:
- `{{TITLE}}` - Note title from YAML
- `{{METADATA}}` - Formatted YAML metadata
- `{{CONTENT}}` - Converted markdown content
- `{{DATE}}` - Export date
- `{{AUTHOR}}` - From YAML or git config
- `{{TAGS}}` - Formatted tags from YAML

### Export Commands

```vim
:NorgExportHTML          " Export to HTML (minimal)
:NorgExportPDF           " Export to PDF (requires pandoc)
:NorgExportSlides        " Export to presentation
:NorgExportOpen          " Open last export in browser/viewer
:NorgExportCheck         " Check for required dependencies
```

### File Structure Changes

```diff
lua/plugins/notes_profile/
+├── export.lua (NEW - 300 lines)
│   ├── export_to_html()
│   ├── export_to_pdf()
│   ├── export_to_presentation()
│   ├── export_picker()
│   ├── check_dependencies()
│   ├── highlight_code_block()
│   └── render_checkboxes()
+└── templates/
+    ├── html-minimal.html (NEW - ~100 lines)
+    ├── html-professional.html (NEW - ~200 lines)
+    ├── pdf-minimal.tex (NEW - ~50 lines)
+    ├── pdf-professional.tex (NEW - ~100 lines)
+    ├── reveal-slides.html (NEW - ~150 lines)
+    └── custom/ (user templates directory)
```

### Testing Checklist

- [ ] HTML export preserves all formatting
- [ ] YAML metadata rendered correctly
- [ ] Code blocks syntax highlighted
- [ ] Checkboxes rendered with correct states
- [ ] Links work in exported HTML
- [ ] Images embedded/linked correctly
- [ ] PDF export works (with pandoc)
- [ ] PDF preserves formatting
- [ ] Presentation export creates slides
- [ ] Custom templates work
- [ ] Export picker shows all options
- [ ] Can open exported file from Neovim
- [ ] Dependency check works
- [ ] Export to same directory as source

### Rollback Procedure

1. Remove `export.lua`
2. Remove templates directory
3. Remove export keybindings
4. No impact on existing functionality

### Success Criteria

✅ HTML export preserves 100% of content  
✅ PDF export works with pandoc installed  
✅ Code blocks properly highlighted  
✅ YAML metadata rendered as header  
✅ Checkboxes show correct states  
✅ Export completes in <5 seconds  
✅ Templates customizable  
✅ Self-contained HTML (no external assets)  

---

## Phase 15: Advanced Text Objects

**Priority:** LOW-MEDIUM  
**Complexity:** High (treesitter integration)  
**Risk:** Low (new module, opt-in)  
**Estimated Lines:** 200 (text-objects.lua)  

### Objective

Implement vim-style text objects for markdown structures using treesitter for precise selection and manipulation.

### Target Text Objects

| Text Object | Description | Example Usage |
|-------------|-------------|---------------|
| `ah` / `ih` | Around/Inside heading section | `dah` = delete heading + content |
| `al` / `il` | Around/Inside list item | `dal` = delete list item + children |
| `ac` / `ic` | Around/Inside checkbox item | `cic` = change checkbox text |
| `ay` / `iy` | Around/Inside YAML frontmatter | `vay` = select all frontmatter |
| `ap` / `ip` | Around/Inside paragraph | `dap` = delete markdown paragraph |
| `ab` / `ib` | Around/Inside code block | `yab` = yank code block with markers |

### Implementation Details

**File:** `lua/plugins/notes_profile/text-objects.lua` (NEW)

### Key Functions

```lua
-- Get heading section (includes all content until next same-level heading)
function M.select_heading(mode)
  -- mode: "around" (ah) or "inside" (ih)
  -- Uses treesitter to find heading node
  -- Extends to next same-level heading
  -- Returns: {start_line, end_line}
end

-- Get list item (includes all nested children)
function M.select_list_item(mode)
  -- mode: "around" (al) or "inside" (il)
  -- Detects indentation level
  -- Includes all child items
  -- Returns: {start_line, end_line}
end

-- Get checkbox item
function M.select_checkbox(mode)
  -- mode: "around" (ac) or "inside" (ic)
  -- around: includes checkbox marker
  -- inside: just the text after checkbox
  -- Returns: {start_col, end_col} (single line)
end

-- Get YAML frontmatter
function M.select_yaml(mode)
  -- mode: "around" (ay) or "inside" (iy)
  -- around: includes --- markers
  -- inside: just the YAML content
  -- Returns: {start_line, end_line}
end

-- Get code block
function M.select_code_block(mode)
  -- mode: "around" (ab) or "inside" (ib)
  -- around: includes ``` markers
  -- inside: just the code content
  -- Returns: {start_line, end_line}
end
```

### Usage Examples

**Heading Text Objects:**
```markdown
## Project Goals        <- cursor here

Content under goals
More content
- List item

## Next Section         <- dah stops here
```

- `dah` - Delete "Project Goals" heading and all content until next same-level heading
- `cih` - Change content inside heading (keep heading line)
- `vah` - Visual select entire heading section

**List Item Text Objects:**
```markdown
- Parent item           <- cursor here
  - Child 1
  - Child 2
    - Nested child
- Next parent           <- dal stops here
```

- `dal` - Delete parent item and all nested children
- `yil` - Yank list content (without marker)
- `val` - Visual select entire list tree

**Checkbox Text Objects:**
```markdown
- [x] Complete this task @remind(tomorrow)
      ^-- cursor here
```

- `cic` - Change "Complete this task @remind(tomorrow)"
- `dic` - Delete just the text, keep checkbox
- `vic` - Visual select text

**YAML Text Objects:**
```markdown
---                     <- cursor anywhere in frontmatter
title: My Note
tags:
  - test
---
```

- `day` - Delete entire frontmatter including ---
- `ciy` - Change YAML content (keep markers)
- `vay` - Visual select entire frontmatter

### Operator Compatibility

These text objects work with all vim operators:

| Operator | Example | Description |
|----------|---------|-------------|
| `d` | `dah` | Delete around heading |
| `c` | `cic` | Change inside checkbox |
| `y` | `yal` | Yank around list item |
| `v` | `vay` | Visual select YAML |
| `>` | `>al` | Indent list item |
| `<` | `<al` | Dedent list item |
| `=` | `=ah` | Format heading section |
| `gq` | `gqip` | Reflow paragraph |

### Integration with Existing Features

**Folding Integration:**
- Text objects respect fold boundaries
- `zf` with text objects creates folds
- Example: `zfah` = fold entire heading section

**Smart Selection:**
- Multiple headings: `v2ah` = select 2 heading sections
- Dot repeat: `dah.` = delete next heading too
- Count support: `3dic` = change 3 checkbox texts

### Treesitter Queries

Use treesitter to identify structures:

```lua
-- Heading query
local heading_query = [[
  (atx_heading) @heading
]]

-- List item query
local list_query = [[
  (list_item) @list
]]

-- Code block query
local code_query = [[
  (fenced_code_block) @code
]]
```

### Configuration

Allow users to customize text objects:

```lua
-- In config.lua
M.text_objects = {
  enabled = true,
  mappings = {
    heading = { around = "ah", inside = "ih" },
    list = { around = "al", inside = "il" },
    checkbox = { around = "ac", inside = "ic" },
    yaml = { around = "ay", inside = "iy" },
    paragraph = { around = "ap", inside = "ip" },
    code_block = { around = "ab", inside = "ib" },
  }
}
```

### File Structure Changes

```diff
lua/plugins/notes_profile/
├── config.lua (updated: add text_objects config)
+├── text-objects.lua (NEW - 200 lines)
│   ├── select_heading()
│   ├── select_list_item()
│   ├── select_checkbox()
│   ├── select_yaml()
│   ├── select_paragraph()
│   ├── select_code_block()
│   └── setup_mappings()
└── markdown-enhancements.lua (updated: require text-objects)
```

### Testing Checklist

- [ ] `dah` deletes heading section correctly
- [ ] `cih` changes content, keeps heading
- [ ] `dal` deletes list item with children
- [ ] `cic` changes checkbox text only
- [ ] `day` deletes entire YAML frontmatter
- [ ] `dab` deletes code block with markers
- [ ] `dib` deletes just code content
- [ ] Text objects work with visual mode
- [ ] Count support works (e.g., `2dah`)
- [ ] Dot repeat works correctly
- [ ] Works with nested structures
- [ ] No conflicts with existing keybindings
- [ ] Performance is good (no lag)

### Rollback Procedure

1. Remove `text-objects.lua`
2. Remove text object mappings
3. System reverts to standard vim text objects

### Success Criteria

✅ Text objects work with all vim operators  
✅ Selection accurate 95%+ of time  
✅ Handles nested structures correctly  
✅ No conflicts with existing mappings  
✅ Treesitter queries are efficient  
✅ No performance degradation  

---

## Phase 16: Enhanced Analytics & Statistics

**Priority:** LOW (nice-to-have)  
**Complexity:** High  
**Risk:** Low (new module, opt-in)  
**Estimated Lines:** 250 (analytics.lua)  

### Objective

Provide rich insights into note collection: backlinks graph, statistics dashboard, orphaned notes detection, and smart tag suggestions.

### Features

1. **Note Graph View** - Visualize connections between notes
2. **Statistics Dashboard** - Comprehensive note analytics
3. **Orphaned Notes Detection** - Find notes without backlinks
4. **Tag Analysis** - Most used tags, tag suggestions
5. **Writing Stats** - Word count trends, productivity metrics

### Implementation Details

**File:** `lua/plugins/notes_profile/analytics.lua` (NEW)

### Key Functions

```lua
-- Build note graph (backlinks map)
function M.build_note_graph()
  -- Scans all notes in workspace
  -- Extracts backlinks
  -- Builds adjacency list
  -- Returns: {nodes, edges}
end

-- Show note graph visualization
function M.show_note_graph(note)
  -- note: current note or specified note
  -- Shows connected notes
  -- Visual representation of connections
  -- Interactive navigation
end

-- Generate statistics dashboard
function M.show_dashboard()
  -- Total notes
  -- Notes by status/tag
  -- Word count stats
  -- Time tracking summary
  -- Checkbox completion rates
  -- Recent activity
end

-- Find orphaned notes
function M.find_orphaned_notes()
  -- Notes with no backlinks
  -- Notes with no tags
  -- Notes not updated recently
  -- Returns: list of orphaned notes
end

-- Suggest tags for current note
function M.suggest_tags()
  -- Analyze note content
  -- Compare with existing tags
  -- Suggest relevant tags
  -- Based on similar notes
end
```

### Note Graph Visualization

When user presses `<leader>vg`:

```
┌─ Note Graph: 2025-12-30-project-plan.md ────────────────┐
│                                                          │
│            Architecture Design                          │
│                   ↑                                      │
│                   |                                      │
│      Project Plan (current) ← Tech Stack                │
│           ↓       ↓                                      │
│   Implementation  Meeting Notes                         │
│                                                          │
│ Connections:                                             │
│   → Links to: 3 notes                                   │
│   ← Linked from: 2 notes                                │
│                                                          │
│ Related by tags:                                         │
│   #project: 5 other notes                               │
│   #planning: 3 other notes                              │
└──────────────────────────────────────────────────────────┘
```

### Statistics Dashboard

When user presses `<leader>va`:

```
┌─ Notes Analytics Dashboard ──────────────────────────────┐
│                                                          │
│ 📊 OVERVIEW                                             │
│   Total Notes:        142                               │
│   Total Words:        47,823                            │
│   Average Length:     337 words/note                    │
│   Last Updated:       2 mins ago                        │
│                                                          │
│ 📝 BY STATUS                                            │
│   Draft:         45 (32%)  ███████░░░░░░░░░░░░░        │
│   In Review:     23 (16%)  ████░░░░░░░░░░░░░░░░        │
│   Published:     58 (41%)  ██████████░░░░░░░░░░        │
│   Archived:      16 (11%)  ███░░░░░░░░░░░░░░░░░        │
│                                                          │
│ 🏷️  TOP TAGS                                            │
│   #project        38 notes                              │
│   #meeting        27 notes                              │
│   #documentation  19 notes                              │
│   #planning       15 notes                              │
│   #review         12 notes                              │
│                                                          │
│ ⏱️  TIME TRACKING (This Week)                          │
│   Total Time:     18h 45m                               │
│   Sessions:       45                                    │
│   Avg/Day:        2h 40m                                │
│   Trend:          ↗ +15%                                │
│                                                          │
│ ✓  TASK COMPLETION                                      │
│   Pending:        28 (35%)  ████████░░░░░░░░░░░        │
│   In Progress:    12 (15%)  ████░░░░░░░░░░░░░░░        │
│   Done:           35 (44%)  ███████████░░░░░░░░        │
│   Cancelled:       5 (6%)   ██░░░░░░░░░░░░░░░░░        │
│   Completion:     44%                                   │
│                                                          │
│ 📅 RECENT ACTIVITY (Last 7 Days)                       │
│   Notes Created:  7                                     │
│   Notes Updated:  23                                    │
│   Most Active:    Wed (8 notes edited)                 │
│                                                          │
│ 🔗 BACKLINKS                                            │
│   Most Linked:    project-overview.md (12 links)       │
│   Orphaned:       3 notes                               │
│   Hub Notes:      5 (>5 connections)                   │
└──────────────────────────────────────────────────────────┘
```

### Orphaned Notes Detection

When user presses `<leader>vo`:

```
┌─ Orphaned Notes (3 found) ───────────────────────────────┐
│                                                          │
│ > 2024-11-15-random-thoughts.md                         │
│   No backlinks | No tags | Last updated: 45 days ago  │
│                                                          │
│   2024-10-22-temp-notes.md                              │
│   No backlinks | 1 tag | Last updated: 69 days ago    │
│                                                          │
│   2024-12-01-draft.md                                   │
│   No backlinks | 2 tags | Last updated: 29 days ago   │
│                                                          │
│ Actions:                                                 │
│   <CR>  Open note                                       │
│   <C-d> Delete note (after confirmation)                │
│   <C-t> Add tags to note                                │
│   <C-l> Create link from current note                   │
└──────────────────────────────────────────────────────────┘
```

### Smart Tag Suggestions

When user presses `<leader>vt`:

```
┌─ Tag Suggestions for: project-planning.md ───────────────┐
│                                                          │
│ Current tags: #project, #planning                       │
│                                                          │
│ Suggested tags based on content:                        │
│   #architecture    (similarity: 87%)                    │
│   #design          (similarity: 82%)                    │
│   #documentation   (similarity: 76%)                    │
│                                                          │
│ Suggested tags from similar notes:                      │
│   #milestone       (used in 3 similar notes)            │
│   #roadmap         (used in 2 similar notes)            │
│                                                          │
│ Frequently co-occurring tags:                           │
│   #project + #milestone  (12 notes)                    │
│   #planning + #roadmap   (8 notes)                     │
│                                                          │
│ Actions:                                                 │
│   <CR>  Add selected tag                                │
│   <C-a> Add all suggested tags                          │
│   <Esc> Cancel                                          │
└──────────────────────────────────────────────────────────┘
```

### New Keybindings

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>va` | Analytics Dashboard | Show comprehensive stats |
| `<leader>vg` | Note Graph | Visualize backlinks for current note |
| `<leader>vo` | Orphaned Notes | Find notes without connections |
| `<leader>vt` | Tag Suggestions | Smart tag recommendations |
| `<leader>vh` | Hub Notes | Find highly connected notes |
| `<leader>vr` | Recent Activity | Show recent note changes |

### File Structure Changes

```diff
lua/plugins/notes_profile/
+├── analytics.lua (NEW - 250 lines)
│   ├── build_note_graph()
│   ├── show_note_graph()
│   ├── show_dashboard()
│   ├── find_orphaned_notes()
│   ├── suggest_tags()
│   ├── find_hub_notes()
│   └── show_recent_activity()
└── markdown-enhancements.lua (updated: require analytics)
```

### Testing Checklist

- [ ] Note graph shows correct connections
- [ ] Dashboard displays accurate statistics
- [ ] Orphaned notes detection works
- [ ] Tag suggestions are relevant
- [ ] Hub notes identified correctly
- [ ] Recent activity tracking works
- [ ] Analytics load in <3 seconds
- [ ] No performance impact on editing
- [ ] Graph navigation is intuitive
- [ ] Can perform actions on orphaned notes

### Rollback Procedure

1. Remove `analytics.lua`
2. Remove analytics keybindings
3. No impact on existing functionality

### Success Criteria

✅ Analytics dashboard loads in <3 seconds  
✅ Note graph accurately shows connections  
✅ Orphaned notes detection finds all disconnected notes  
✅ Tag suggestions are contextually relevant  
✅ Statistics are accurate and up-to-date  
✅ No performance degradation  

---

## Implementation Strategy

### Order of Implementation

**Recommended Session Plan:**

| Session | Phases | Complexity | Lines | Duration |
|---------|--------|------------|-------|----------|
| **Session 1** | Phase 0 + Phase 11 | Low-Medium | ~350 | 1-2 hours |
| **Session 2** | Phase 12 | Medium | ~150 | 1 hour |
| **Session 3** | Phase 13 | Medium | ~250 | 1-2 hours |
| **Session 4** | Phase 14 | High | ~300 | 2 hours |
| **Session 5** | Phase 15 (Optional) | High | ~200 | 1-2 hours |
| **Session 6** | Phase 16 (Optional) | High | ~250 | 1-2 hours |

**Flexible Approach:**
- Simple phases (0, 11, 12) can be combined
- Complex phases (14, 15, 16) best done separately
- Can stop after any phase and use implemented features

### Git Workflow

**Branch Structure:**
```
main
└── feature/neorg-enhancements (main feature branch) ← current
    ├── feature/neorg-enhancements-phase-00-refactor
    ├── feature/neorg-enhancements-phase-11-checkboxes
    ├── feature/neorg-enhancements-phase-12-workspaces
    ├── feature/neorg-enhancements-phase-13-timetracking
    ├── feature/neorg-enhancements-phase-14-export
    ├── feature/neorg-enhancements-phase-15-textobjects
    └── feature/neorg-enhancements-phase-16-analytics
```

**Workflow Per Phase:**

1. **Start Phase:**
   ```bash
   git checkout feature/neorg-enhancements
   git pull origin feature/neorg-enhancements
   git checkout -b feature/neorg-enhancements-phase-XX-name
   ```

2. **During Development:**
   ```bash
   # Make changes
   git add .
   git commit -m "feat(phase-XX): description of changes"
   
   # Regular commits
   git commit -m "feat(phase-XX): add function X"
   git commit -m "test(phase-XX): add tests for Y"
   git commit -m "docs(phase-XX): update documentation"
   ```

3. **Complete Phase:**
   ```bash
   # Merge back to main feature branch
   git checkout feature/neorg-enhancements
   git merge --no-ff feature/neorg-enhancements-phase-XX-name
   git branch -d feature/neorg-enhancements-phase-XX-name
   
   # Update this document
   # Mark phase as completed in NEORG_INSPIRED_ENHANCEMENTS.md
   git add NEORG_INSPIRED_ENHANCEMENTS.md
   git commit -m "docs: mark phase XX as completed"
   ```

4. **After All Phases:**
   ```bash
   # Merge to main
   git checkout main
   git merge --no-ff feature/neorg-enhancements
   
   # Tag the release
   git tag -a v1.0.0-neorg-enhancements -m "Complete Neorg-inspired enhancements"
   git push origin main --tags
   ```

### Commit Message Convention

Format: `<type>(scope): <description>`

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions/changes
- `refactor`: Code refactoring
- `style`: Code style changes (formatting)
- `chore`: Build/config changes

**Examples:**
```
feat(phase-11): add multi-state checkbox cycling
feat(phase-12): implement workspace switching
fix(phase-11): correct state persistence in YAML
docs(phase-13): add time tracking usage examples
test(phase-12): add workspace validation tests
refactor(phase-00): extract checkbox functions to module
```

### Testing Protocol

**Per Phase Testing:**

1. **Unit Tests** (function-level)
   - Test each new function independently
   - Mock external dependencies
   - Verify edge cases

2. **Integration Tests** (module-level)
   - Test module interactions
   - Verify data flow between modules
   - Check configuration loading

3. **System Tests** (end-to-end)
   - Test complete workflows
   - Verify all keybindings work
   - Check for performance regressions

4. **Regression Tests** (existing features)
   - Ensure all existing features still work
   - No broken keybindings
   - No Lua errors on startup

**Test Workspace Setup:**

Create test workspace with sample data:
```bash
mkdir -p /tmp/neorg-test-vault

# Create test notes
cat > /tmp/neorg-test-vault/test-checkboxes.md << 'EOF'
---
title: Checkbox Test
created: 2025-12-30 10:00:00
updated: 2025-12-30 10:00:00
tags:
  - test
---

# Checkbox Tests

- [ ] Pending task
- [-] In progress task
- [x] Completed task
- [_] Cancelled task

## Nested Tasks
- [ ] Parent task
  - [ ] Child task 1
  - [x] Child task 2
## Keybindings Reference

### Complete Keybindings List

All keybindings organized by feature area:

#### Checkboxes (Phase 11)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>cx` | Cycle Forward | Cycle checkbox state forward |
| `<leader>cX` | Cycle Backward | Cycle checkbox state backward |
| `<leader>cs` | Show Statistics | Display checkbox counts |
| `<leader>cp` | Set Pending | Set to `[ ]` |
| `<leader>ci` | Set In Progress | Set to `[-]` (also: insert checkbox) |
| `<leader>cd` | Set Done | Set to `[x]` |
| `<leader>cc` | Set Cancelled | Set to `[_]` |
| `<leader>cm` | Move to DONE | Move completed item to DONE section |
| `<leader>cM` | Migrate Format | Migrate old checkbox format |

#### Workspaces (Phase 12)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ws` | Switch Workspace | Open workspace picker |
| `<leader>wl` | List Workspaces | Show all workspaces |
| `<leader>wc` | Current Workspace | Show current workspace details |
| `<leader>wn` | New Workspace | Create a new workspace |
| `<leader>wv` | Validate Workspace | Check workspace accessibility |

#### Time Tracking (Phase 13)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>tp` | Start Pomodoro | Start 25m timer (enhanced with logging) |
| `<leader>tm` | Mark Session | Mark Pomodoro session (also: Monthly report) |
| `<leader>ts` | Short Rest | Start 5m rest timer |
| `<leader>tl` | Long Rest | Start 10m rest timer |
| `<leader>td` | Daily Report | Show today's time tracking |
| `<leader>tw` | Weekly Report | Show current week's tracking |
| `<leader>tt` | Task Log | Search time logs by task |
| `<leader>tq` | Query Logs | Custom query with filters |
| `<leader>te` | Export Logs | Export to CSV/JSON |

#### Export (Phase 14)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>eh` | Export HTML | Quick export to HTML |
| `<leader>ep` | Export PDF | Quick export to PDF |
| `<leader>es` | Export Slides | Export to presentation |
| `<leader>ee` | Export Picker | Choose format and template |
| `<leader>eo` | Open Export | Open last exported file |
| `<leader>ec` | Check Dependencies | Check for pandoc |

#### Analytics (Phase 16)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>va` | Analytics Dashboard | Show comprehensive stats |
| `<leader>vg` | Note Graph | Visualize backlinks |
| `<leader>vo` | Orphaned Notes | Find unconnected notes |
| `<leader>vt` | Tag Suggestions | Smart tag recommendations |
| `<leader>vh` | Hub Notes | Find highly connected notes |
| `<leader>vr` | Recent Activity | Show recent changes |

#### Existing Keybindings (Unchanged)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>xt` | Trouble TODOs | Open TODO list |
| `<leader>sh` | Search Headings | Navigate to heading |
| `<leader>fn` | Full-Text Search | Search in notes vault |
| `<leader>bl` | Insert Backlink | Link to another note |
| `<leader>ym` | Show Metadata | Display YAML frontmatter |
| `<leader>yh` | Insert YAML | Insert frontmatter template |
| `<leader>yhm` | Meeting Template | Insert meeting note template |
| `<leader>ys` | YAML Search | Search notes by metadata |
| `<leader>yf` | Toggle YAML Fold | Fold/unfold frontmatter |
| `<leader>yr` | Rename from YAML | Rename file based on metadata |
| `<leader>rc` | Create Reminder | Mac Reminder from checkbox |
| `<leader>rs` | Sync Reminders | Sync all reminders to Mac |
| `<leader>toc` | Generate TOC | Create table of contents |
| `<leader>wc` | Word Count | Show word/character count |
| `<leader>mb` | Bold | Markdown bold |
| `<leader>mi` | Italic | Markdown italic |
| `<leader>ms` | Strikethrough | Markdown strikethrough |
| `<leader>mc` | Inline Code | Markdown inline code |
| `<leader>mC` | Code Block | Markdown code block |
| `<leader>mf` | Enable Folding | Re-enable markdown folding |
| `<leader>p` | Paste Image | Paste image from clipboard |

### Text Objects (Phase 15)
| Object | Description | Example Usage |
|--------|-------------|---------------|
| `ah` / `ih` | Around/Inside heading | `dah` = delete heading section |
| `al` / `il` | Around/Inside list | `dal` = delete list with children |
| `ac` / `ic` | Around/Inside checkbox | `cic` = change checkbox text |
| `ay` / `iy` | Around/Inside YAML | `vay` = select frontmatter |
| `ap` / `ip` | Around/Inside paragraph | `dap` = delete paragraph |
| `ab` / `ib` | Around/Inside code block | `yab` = yank code block |

---

## Breaking Changes Log

### Phase 0: Path Refactoring
**Breaking:** None (internal refactoring only)

**Migration:** None required

### Phase 11: Multi-State Checkboxes
**Breaking:** `<leader>cx` behavior changed
- **Before:** Simple toggle `[ ]` ↔ `[x]`
- **After:** Cycle through 4 states `[ ]` → `[-]` → `[x]` → `[_]` → `[ ]`

**Migration:** 
- Old behavior still works (toggle between `[ ]` and `[x]`)
- Use `<leader>cM` to migrate to new format when ready
- Manual migration recommended (not automatic)

### Phase 12: Workspace Management
**Breaking:** None (additive only)

**Migration:** None required

### Phase 13: Time Tracking
**Breaking:** Pomodoro keybindings enhanced
- **Before:** `<leader>tp` just started timer
- **After:** `<leader>tp` starts timer + registers for auto-logging

**Migration:** None required (backward compatible)

### Phase 14: Export System
**Breaking:** None (new feature)

**Migration:** None required

### Phase 15: Text Objects
**Breaking:** None (new feature, opt-in)

**Migration:** None required

### Phase 16: Analytics
**Breaking:** None (new feature)

**Migration:** None required

---

## Rollback Procedures

### Complete Rollback (All Phases)

```bash
# 1. Switch to backup branch
git checkout main
git log --oneline -10  # Find commit before merge

# 2. Create rollback branch
git checkout -b rollback-neorg-enhancements <commit-hash-before-merge>

# 3. Test that everything works
nvim test-file.md

# 4. If satisfied, force update main
git checkout main
git reset --hard <commit-hash-before-merge>
git push --force-with-lease
```

### Individual Phase Rollback

Each phase can be rolled back independently:

**Phase 0 Rollback:**
1. Restore original `markdown-enhancements.lua.backup`
2. Delete new module files
3. Restart Neovim

**Phase 11 Rollback:**
1. Delete `checkbox-manager.lua`
2. Restore original `toggle_checkbox()` function
3. Remove new keybindings

**Phase 12 Rollback:**
1. Delete `workspace-manager.lua`
2. Revert hardcoded paths in other modules
3. Remove workspace keybindings

**Phase 13 Rollback:**
1. Delete `time-tracker.lua`
2. Revert Pomodoro integration changes
3. Remove time tracking keybindings

**Phase 14 Rollback:**
1. Delete `export.lua`
2. Delete `templates/` directory
3. Remove export keybindings

**Phase 15 Rollback:**
1. Delete `text-objects.lua`
2. Remove text object mappings

**Phase 16 Rollback:**
1. Delete `analytics.lua`
2. Remove analytics keybindings

---

## Cross-Session Context for LLMs

### Context Overview

This section provides critical information for future LLM sessions continuing this project.

### Project State

**Current Phase:** Planning (Document Creation)  
**Branch:** `feature/neorg-enhancements`  
**Status:** Ready to begin Phase 0  

### Key Decisions Made

1. **Modular Split:** Split 1,230-line file into 7+ modules
2. **Multi-State Checkboxes:** 4 states (Pending, In Progress, Done, Cancelled)
3. **Workspace Management:** Multi-vault with persistent active workspace
4. **Dual Storage:** Time logs in both YAML (portable) and JSON (queryable)
5. **Export Templates:** Both built-in and user-customizable templates
6. **Text Objects:** Treesitter-based for precision
7. **Manual Migration:** Checkbox format migration is opt-in, not automatic

### User Preferences

- **Breaking Changes:** Moderate tolerance (not dramatic)
- **Export Priorities:** HTML > PDF > Presentation
- **Time Tracking:** Intermediate (not basic, not advanced)
- **Code Tangling:** Low priority (reference only)
- **Documentation:** Single large file preferred

### Critical Files

1. **This Document:** `NEORG_INSPIRED_ENHANCEMENTS.md` - Master plan
2. **Main Config:** `lua/plugins/notes_profile/config.lua` - Shared configuration
3. **Notes Plan:** `NOTES_SETUP_PLAN.md` - Original notes setup documentation
4. **Main Enhancement:** `lua/plugins/notes_profile/markdown-enhancements.lua` - 1,230 lines to refactor

### Path Configuration

**Current Hardcoded Path:**
```
~/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault
```

**Found in:**
- `markdown-enhancements.lua` lines: 555, 973, 982, 1021

**Test Workspace:**
```
/tmp/neorg-test-vault
```

### Next Steps for Implementation

**Session 1 Tasks:**
1. Create `config.lua` with workspace configuration
2. Split `markdown-enhancements.lua` into modules:
   - `checkbox-core.lua`
   - `yaml-manager.lua`
   - `navigation.lua`
   - `reminders.lua`
   - `pomodoro-integration.lua`
3. Test all existing features work
4. Implement Phase 11 (Multi-State Checkboxes)
5. Test checkbox cycling
6. Update documentation

### Questions to Ask User at Session Start

1. "Are you ready to proceed with Phase [X]?"
2. "Have you backed up your configuration?"
3. "Do you want to proceed with one or multiple phases?"
4. "Any concerns or changes to the plan?"

### Common Issues to Watch For

1. **Path Resolution:** Test that workspace paths work on user's system
2. **YAML Parsing:** Frontmatter format variations
3. **Treesitter:** Ensure treesitter is properly configured
4. **Performance:** Monitor startup time and operation speed
5. **Conflicts:** Check for keybinding conflicts with existing plugins

### Testing Commands

```vim
" Test existing features
:edit ~/path/to/test-note.md
:NorgWorkspaceSwitch test
:TodoTrouble
:TimerStart 1m Test

" Check for errors
:checkhealth notes_profile
:messages

" Validate configuration
:lua require("plugins.notes_profile.config").validate_config()
```

### Useful Debugging

```lua
-- Add to any function for debugging
vim.print(variable_name)  -- Pretty print
vim.inspect(table_name)   -- Inspect table structure
vim.notify("Debug: " .. tostring(value), vim.log.levels.DEBUG)
```

### File Locations Reference

**Config:**
- Neovim config root: `~/.config/nvim/`
- Plugin directory: `~/.config/nvim/lua/plugins/notes_profile/`
- State directory: `~/.local/state/nvim/notes_profile/`
- Data directory: `~/.local/share/nvim/notes_profile/`

**Notes:**
- Work vault: `~/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault`
- Test vault: `/tmp/neorg-test-vault`

---

## Future Considerations

### After All Phases Complete

**Potential Next Steps:**

1. **Documentation:**
   - Create video walkthrough
   - Write blog post comparing Markdown vs Neorg approach
   - Create quick reference cheat sheet
   - Add to README.md

2. **Community:**
   - Consider publishing as standalone plugin
   - Share on Reddit (r/neovim)
   - Submit to awesome-neovim
   - Create discussions thread for feedback

3. **Improvements:**
   - AI integration for note summarization
   - Mobile companion app
   - Web interface for notes browsing
   - Collaborative editing support
   - Git integration for version control

### Possible Phase 17+ Ideas

**Phase 17: AI Integration**
- Summarize long notes
- Generate titles from content
- Suggest related notes
- Auto-tag based on content

**Phase 18: Mobile Sync**
- iOS/Android app integration
- Conflict resolution
- Offline support
- Push notifications for reminders

**Phase 19: Web Interface**
- Read-only web viewer
- Search interface
- Graph visualization
- Markdown rendering

**Phase 20: Collaboration**
- Real-time editing
- Comments and discussions
- Shared workspaces
- Activity feed

**Phase 21: Version Control**
- Git-based version history
- Diff visualization
- Restore previous versions
- Branch-based workflows

---

## Conclusion

This comprehensive plan provides a roadmap for enhancing the markdown note-taking system with Neorg-inspired features while maintaining the universal Markdown format.

### Summary of Enhancements

- **Phase 0:** Modular architecture for maintainability
- **Phase 11:** Multi-state checkboxes for workflow tracking
- **Phase 12:** Multi-workspace support for organization
- **Phase 13:** Time tracking with reports and analytics
- **Phase 14:** Export to HTML, PDF, and presentations
- **Phase 15:** Advanced text objects for efficient editing
- **Phase 16:** Analytics and insights for note collection

### Total Estimated Impact

- **New Features:** 6 major enhancements
- **New Modules:** 8 Lua files
- **New Lines of Code:** ~1,400 lines
- **Estimated Time:** 6-12 hours across 3-6 sessions
- **Breaking Changes:** Minimal (mostly additive)

### Success Definition

This project will be considered successful when:
1. All phases implemented and tested
2. No regression in existing features
3. Documentation complete and accurate
4. Performance acceptable (no noticeable degradation)
5. User satisfied with new capabilities

---

**Document Status:** Complete and ready for implementation  
**Last Updated:** 2025-12-30  
**Version:** 1.0  

---

