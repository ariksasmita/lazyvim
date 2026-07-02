# Git Enhancement Plan

## Overview
Add custom git blame and diff view features inspired by EcoVim configuration.

## Plugins to Add
1. **FabijanZulj/blame.nvim** - Side panel git blame
2. **dlyongemallo/diffview.nvim** - Diff viewer with custom toggle functions
3. **lewis6991/gitsigns.nvim** - Inline diffs + line blame (already in lazy-lock)

## Implementation Plan

### 1. Create Git Plugin Structure
- Create `lua/plugins/git/` directory
- Create `lua/plugins/git/blame.lua` - blame.nvim configuration
- Create `lua/plugins/git/diffview.lua` - diffview.nvim configuration
- Create `lua/plugins/git/gitsigns.lua` - gitsigns.nvim configuration

### 2. Configure blame.nvim
- Plugin: `FabijanZulj/blame.nvim`
- Command: `BlameToggle` to toggle side panel
- Keybinding: `<leader>gb` for blame panel

### 3. Configure diffview.nvim
- Plugin: `dlyongemallo/diffview.nvim`
- Custom toggle functions:
  - `toggle_file_history()` - toggle file's git history
  - `toggle_status()` - toggle working tree diff
- Keybindings:
  - `<leader>gd` - diff file history
  - `<leader>gD` - diff view open
  - `<leader>gS` - diff status

### 4. Configure gitsigns.nvim
- Plugin: `lewis6991/gitsigns.nvim`
- Enable inline diff signs
- Enable current line blame
- Keybindings:
  - `]c` / `[c` - next/previous hunk
  - `<leader>ghs` - stage hunk
  - `<leader>ghr` - reset hunk
  - `<leader>ghp` - preview hunk
  - `<leader>ghd` - diff hunk
  - `<leader>gm` - blame line (full commit)
  - `<leader>ght` - toggle deleted
  - `<leader>ghS` - stage buffer
  - `<leader>ghR` - reset buffer

### 5. Excluded Features
- ~~octo.nvim~~ - GitHub PR/issues management (excluded by user)

## Keybinding Summary

| Keybinding | Command | Description |
|------------|---------|-------------|
| `<leader>gb` | `BlameToggle` | Toggle side blame panel |
| `<leader>gm` | `gs.blame_line({ full = true })` | Blame line (full commit) |
| `<leader>gd` | `toggle_file_history()` | Diff file history |
| `<leader>gD` | `diffview.open()` | Diff view open |
| `<leader>gS` | `toggle_status()` | Diff status |
| `]c` / `[c` | Navigation | Next/previous hunk |
| `<leader>ghs` | `gs.stage_hunk` | Stage hunk |
| `<leader>ghr` | `gs.reset_hunk` | Reset hunk |
| `<leader>ghp` | `gs.preview_hunk` | Preview hunk |
| `<leader>ghd` | `gs.diffthis` | Diff hunk |
| `<leader>ght` | `gs.toggle_deleted` | Toggle deleted |
| `<leader>ghS` | `gs.stage_buffer` | Stage buffer |
| `<leader>ghR` | `gs.reset_buffer` | Reset buffer |

## Files to Create
1. `/lua/plugins/git/blame.lua`
2. `/lua/plugins/git/diffview.lua`
3. `/lua/plugins/git/gitsigns.lua`

## Implementation Status: ✅ COMPLETED

### Files Created
- ✅ `/lua/plugins/git/blame.lua` - blame.nvim configuration
- ✅ `/lua/plugins/git/diffview.lua` - diffview.nvim plugin spec
- ✅ `/lua/plugins/git/diffview_helper.lua` - diffview toggle helper functions
- ✅ `/lua/plugins/git/gitsigns.lua` - gitsigns.nvim configuration

### Testing Checklist
- [ ] blame.nvim side panel toggles with `<leader>gb`
- [ ] diffview file history toggles with `<leader>gd`
- [ ] diffview status toggles with `<leader>gS`
- [ ] gitsigns inline diffs show
- [ ] gitsigns line blame shows
- [ ] All keybindings work as expected

### Next Steps
1. Reload Neovim to install the new plugins
2. Test each keybinding
3. Report any issues
