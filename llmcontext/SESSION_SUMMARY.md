# Gemini CLI Session Summary: Neovim Note-Taking & Task Management Setup

**Date of Summary Generation:** December 8, 2025

---

## 1. Initial User Goal

The user's primary goal was to enhance their Neovim setup for Markdown note-taking, specifically to:
*   Create links between documents.
*   Paste screenshot images directly from the clipboard, with an emphasis on efficiency and clean integration.
*   Seek suggestions for general note-taking and task management improvements.

---

## 2. Key Issues Encountered & Solutions Implemented

This section details the challenges we faced and how they were addressed.

### 2.1 Image Pasting from Clipboard (Complex Journey)

*   **Initial Proposal:** `ekickx/clipboard-image.nvim`.
*   **Problem 1 (Plugin API Mismatch):** The plugin was not exposing the `paste` function as expected (`attempt to call field 'paste' (a nil value)`).
    *   **Attempted Fixes:**
        *   Renamed config file from `clipboard-image.lua` to `clipboard-image-settings.lua` (initial thought was name collision, but this wasn't the root cause).
        *   Restructured plugin config to use various `lazy.nvim` patterns (`config` function, `keys` table, `init` function) for better loading, but the `paste` function remained `nil`.
        *   Added debug output (`vim.inspect`) which confirmed the loaded module was incomplete.
        *   Attempted a hack using `package.preload` to inject a fake `health` module to bypass an internal plugin dependency issue (`module 'health' not found`).
    *   **Outcome:** `ekickx/clipboard-image.nvim` was deemed fundamentally incompatible or problematic in the user's environment. Abandoned.
*   **Problem 2 (Network Access Block):**
    *   **Subsequent Proposals:** `h-michael/paste.nvim` and `askfiy/nvim-image-clipboard`.
    *   **User Report:** Both proposals resulted in "repo not found" / "404" errors when attempting to clone from GitHub. This was identified as a persistent network-level block on the user's side, preventing access to public GitHub repositories.
    *   **Impact:** Installing any new community plugins from GitHub became impossible.
*   **Final Solution (Custom Script):**
    *   **Approach:** Developed a custom Lua script (`local-paste-image.lua`) that has no external GitHub dependencies.
    *   **Functionality:**
        *   Uses `pngpaste` (macOS CLI tool, `brew install pngpaste` required) to get image data.
        *   Saves images to an `assets/` subdirectory relative to the Markdown file.
        *   Inserts a relative Markdown link (`![]()`).
    *   **Refinements:**
        *   **Image Compression:** Integrated `sips` (macOS built-in tool) for post-processing.
        *   **Compression Tuning:** Initially resized to 2400px max dimension and converted to JPEG (75% quality).
        *   **User Feedback:** User requested removing resizing (`-Z`) for faster processing, prioritizing speed over extreme dimensional reduction.
        *   **Error Fix:** Corrected an error with `vim.fn.stdpath("tmp")` to `vim.fn.tempname()` for temporary file paths.
    *   **Status:** **Working and optimized for user's preference.**

### 2.2 Colorscheme Switching for Markdown

*   **Goal:** Use `github_light_default` for Markdown files and `github_dark_high_contrast` as the general default.
*   **Implementation:** Custom Lua script (`markdown-theming.lua`) using Neovim autocommands (`BufEnter`, `BufWinLeave`, `VimEnter`).
*   **Logic:**
    *   Detects `filetype == 'markdown'` to apply `github_light_default`.
    *   Reverts to `github_dark_high_contrast` when leaving markdown contexts (even in split windows) by checking visible buffers.
*   **Fixes:**
    *   **Problem 1 (Lazy.nvim Error):** Initial script did not return a table, causing `Invalid plugin spec` error.
    *   **Problem 2 (Lazy.nvim Error):** Subsequent attempt to create a dummy `lazy.nvim` spec (`name`, `event`, `config`) was also rejected by `lazy.nvim` as invalid.
    *   **Final Solution:** Restructured `markdown-theming.lua` to follow the simple script pattern (just like `local-paste-image.lua`), defining functionality and returning an empty table `{}`.
*   **Status:** **Working.**

### 2.3 `toppair-peek-md` Preview Theming

*   **Goal:** Ensure the Markdown preview is always light-themed.
*   **Implementation:** Explicitly set `theme = 'light'` in the `peek.setup` options within `toppair-peek-md.lua`.
*   **Status:** **Working.**

### 2.4 Telescope Keymap (`<leader>ff`)

*   **Issue:** User reported Neovim closing when using `<leader>ff`.
*   **Diagnosis:** Ruled out mapping error (Telescope command was correctly mapped). Traced to an issue with the user's terminal emulator (Warp).
*   **Status:** **Resolved (external terminal issue).**

### 2.5 `headlines.nvim` Integration

*   **Goal:** Enhance visual styling of Markdown headers directly in the editor.
*   **Implementation:** Added `lukas-reineke/headlines.nvim` configuration (`headlines.lua`).
*   **Conflict Clarification:** Confirmed it does not conflict with the Markdown previewer (they serve different purposes: in-editor styling vs. rendered output preview).
*   **Status:** **Working.**

### 2.6 Dataview-like Feature

*   **Goal:** Replicate Obsidian's Dataview functionality (querying metadata in notes).
*   **Proposals:** `MDeiml/dataview.nvim`, then `crispgm/dataview.nvim`.
*   **Problem:** User consistently reported 404s for all proposed plugins from GitHub. Confirmed to be a network access issue on the user's side.
*   **Status:** **Unresolved.** Cannot proceed due to inability to access GitHub repositories. Feature requires complex plugin not feasible to custom-script.

---

### 2.7 Modular Refactoring (Phase 0 - 2026-01-01)

* **Goal:** Refactor monolithic configuration into modular architecture for better maintainability.
* **Problem:**
  * Original `markdown-enhancements.lua` was becoming too large
  * "Invalid plugin spec" errors due to lazy.nvim auto-detecting non-plugin modules
  * `local-paste-image.lua` was a dummy plugin causing warnings
* **Implementation:**
  * Created `lua/notes_profile_modules/` for shared modules (not auto-detected by lazy.nvim)
  * Extracted modules:
    * `config.lua` - Workspace paths, checkbox states, time tracking config
    * `checkbox-core.lua` - Checkbox management (toggle, move to done, insert)
    * `reminders.lua` - Mac Reminders integration
    * `navigation.lua` - Workspace navigation and search functions
    * `local-paste-image.lua` - Image pasting functionality
  * Moved `local-paste-image.lua` from `lua/plugins/` to `lua/notes_profile_modules/`
  * Added autocmd in `lua/config/autocmds.lua` to load paste image keymap only for markdown buffers
  * Updated all `require()` statements to use new paths
* **Architecture:**
  ```
  lua/plugins/notes_profile/       ← Auto-detected by lazy.nvim
    ├── conform.lua                 ← Plugin spec
    ├── headlines.lua               ← Plugin spec
    ├── markdown-enhancements.lua   ← Plugin spec
    ├── marksman-lint-config.lua    ← Plugin spec
    └── trouble.lua                 ← Plugin spec

  lua/notes_profile_modules/        ← Manual require() only
    ├── config.lua                  ← Configuration
    ├── checkbox-core.lua           ← Checkbox functions
    ├── reminders.lua               ← Reminders integration
    ├── navigation.lua              ← Navigation functions
    └── local-paste-image.lua       ← Image pasting
  ```
* **Benefits:**
  * ✅ No more "Invalid plugin spec" errors
  * ✅ Clean separation: plugins = external, modules = internal code
  * ✅ Better code organization
  * ✅ Easier to maintain and extend
* **Status:** **Complete.**
* **Next:** Phase 11 - Multi-State Checkbox Cycle implementation

---

## 3. Future Setup Plan

A detailed plan, `NOTES_SETUP_PLAN.md`, has been created to guide the future development of the Neovim note-taking and task management setup.

*   **Location:** `~/config/nvim/lua/plugins/NOTES_SETUP_PLAN.md`
*   **Modularity Strategy:** The plan outlines restructuring the `lua/plugins/` directory into `base/` (for core plugins) and `notes_profile/` (for new note-taking specific plugins). This requires a manual modification to the user's `lazy.nvim` setup call.
*   **Phases:**
    *   Phase 1: Creating a Modular Foundation (directory restructuring).
    *   Phase 2: Core Note-Taking Features (Telescope, Marksman LSP, `headlines.nvim`, `local-paste-image.lua`).
    *   Phase 3: Task Management (`todo-tree.nvim`).
*   **Current Status:** Ready to begin Phase 1.

---

# NEORG-INSPIRED ENHANCEMENTS PROJECT

**Project Start:** December 30, 2025
**Branch:** `feature/neorg-enhancements`
**Documentation:** `NEORG_INSPIRED_ENHANCEMENTS.md` (comprehensive plan), `PHASE_TRACKER.md` (working status)

## Project Overview

**Goal:** Integrate Neorg's best features into existing Markdown-based note-taking system while maintaining universal `.md` format compatibility.

**Philosophy:**
- Keep Markdown format (universal compatibility)
- Enhance, don't replace existing workflows
- Modular design (each feature independently toggleable)
- Future-proof for multi-workspace, multi-platform usage

**Planned Phases:**
- Phase 0: Path Refactoring & Modular Split ✅
- Phase 11: Multi-State Checkbox System ✅
- Phase 12: Workspace Management (Pending)
- Phase 13: Time Tracking Enhancement (Pending)
- Phase 14: Export System (Pending)
- Phase 15: Advanced Text Objects (Pending)
- Phase 16: Enhanced Analytics (Pending)

---

## Phase 0: Modular Refactoring (COMPLETED ✅)

**Date:** 2026-01-01

**What Was Done:**
- Split 1,230-line monolithic `markdown-enhancements.lua` into modular architecture
- Created `lua/notes_profile_modules/` for shared modules (not auto-detected by lazy.nvim)
- Extracted hardcoded OneDrive paths to centralized config

**New Architecture:**
```
lua/plugins/notes_profile/       ← Auto-detected by lazy.nvim (external plugins)
├── conform.lua                 ← Plugin spec
├── headlines.lua               ← Plugin spec
├── markdown-enhancements.lua   ← Plugin spec (refactored, ~400 lines)
├── marksman-lint-config.lua    ← Plugin spec
└── trouble.lua                 ← Plugin spec

lua/notes_profile_modules/        ← Manual require() only (internal modules)
├── config.lua                  ← Configuration, paths, constants
├── checkbox-core.lua           ← Checkbox functions
├── reminders.lua               ← Mac Reminders integration
├── navigation.lua              ← Navigation functions
└── local-paste-image.lua       ← Image pasting
```

**Benefits:**
- ✅ No more "Invalid plugin spec" errors
- ✅ Clean separation: plugins = external, modules = internal
- ✅ Better code organization and maintainability
- ✅ Foundation ready for future enhancements

---

## Phase 11: Multi-State Checkbox System (COMPLETED ✅)

**Date:** 2026-01-02 to 2026-01-13

**What Was Done:**

### 1. Implemented 4-State Checkbox System
- **States:** `[ ]` Pending, `[-]` In Progress, `[x]` Done, `[_]` Cancelled
- **NerdFont Icons:** 󰄱, 󰔛, 󰄵, 󰅰
- **Cycling:** Forward (`[ ]` → `[-]` → `[x]` → `[_]` → `[ ]`) and backward

### 2. Plugin Migration: render-markdown.nvim → markview.nvim
**Why:** render-markdown.nvim couldn't natively support `[_]` cancelled state

**Benefits of markview.nvim:**
- Native support for all 4 checkbox states
- Proper highlight groups for each state
- Hybrid editing mode (edit while previewing)
- Split view support
- Better configuration flexibility

**Files Changed:**
- `lua/plugins/base/markview.lua` (NEW - replaced render-markdown.lua)
- `lua/plugins/base/render-markdown.lua.disabled` (old plugin, disabled)
- `lua/plugins/base/render-markdown.lua.backup` (backup saved)

### 3. YAML Folding Implementation (Journey)

**Initial Attempt:**
- Implemented comprehensive folding: YAML frontmatter + Headers + Lists + Code blocks
- Used `foldmethod = "expr"` with custom `markdown_fold_expr()` function
- Custom foldtext to show state icons and heading levels

**Problem Discovered:**
- Code block folding conflicted with list folding (code blocks inside lists)
- Lists without language identifiers (e.g., `    code` instead of ```` ```text ````) were unreliable
- Complex logic made folding fragile

**Solution:**
- ✅ **Kept:** YAML frontmatter folding (conditional, with `<leader>yf>` toggle)
- ✅ **Kept:** Header-based folding (H1-H6 with proper nesting)
- ✅ **Kept:** List item folding (nested/indented items)
- ❌ **Removed:** Code block folding (too complex, markview renders them nicely anyway)

**Final YAML Folding Implementation:**
- Conditional folding using `vim.b.yaml_fold_enabled` flag
- Only folds when enabled (allows markview to render YAML when unfolded)
- Toggle with `<leader>yf>` keybinding
- Foldtext shows: `YAML Frontmatter: [title]  [X lines]`

### 4. List Indentation Feature (2026-01-13)

**What Was Added:**
- Tab/Shift-Tab to increase/decrease list item indentation
- Works in **Insert mode only** (Normal mode intentionally removed to preserve buffer cycling)
- Uses `<C-o>>>` and `<C-o><<` for smooth indentation without mode switching
- Supports: `-`, `*`, `+`, and numbered lists (`1.`, `2.`, etc.)

**Keybindings:**
- Insert mode: `<Tab>` (indent), `<S-Tab>` (unindent)
- Respects `shiftwidth` setting (default 2 spaces)

**Usage:**
```
- Top level item
  - Nested item (Tab once)
    - Double nested (Tab twice)
- Back to top level (Shift+Tab twice)
```

**File Modified:** `lua/plugins/notes_profile/markdown-enhancements.lua:1210-1292`

---

## YAML Folding & Formatting Issues (OFF-TOPIC EXPLORATION)

### Issue 1: Treesitter Crash (December 30, 2025)

**Problem:**
- Neovim crashed when pressing `:` (command mode)
- Error: `Query error at 113:4. Invalid node type "tab"`

**Root Causes:**
1. **Missing `tree-sitter-cli`:** LazyVim update added requirement for tree-sitter-cli, but Mason couldn't install it
2. **Broken Query File:** nvim-treesitter's vim query file referenced invalid "tab" node type

**Solution:**
1. Installed `tree-sitter-cli` via Homebrew:
   ```bash
   brew install tree-sitter-cli
   ```
2. Patched query file at `~/.local/share/nvim/lazy/nvim-treesitter/runtime/queries/vim/highlights.scm:113`
3. Updated config: `lua/plugins/base/treesitter.lua`
   - Added `auto_install = false`
   - Added `highlight.disable = { "vim" }`

**Status:** ✅ **RESOLVED**

**Warning:** Query file patch will be overwritten if you run `:Lazy update` or `:TSUpdate`

**Documentation:** `TROUBLESHOOTING_LOG.md`

### Issue 2: YAML Frontmatter Not Formatting (Current - 2026-01-02)

**Status:** ⚠️ **KNOWN ISSUE**

**Problem:**
- markview.nvim YAML configuration added but icons not displaying in frontmatter
- YAML section shows as plain text without special formatting

**Current Workaround:**
- Conditional YAML folding allows markview to render YAML when unfolded
- Toggle with `<leader>yf>` to fold/unfold

**Potential Fixes to Explore:**
1. Check markview.nvim YAML configuration syntax
2. Verify conceallevel settings for markdown
3. Test different YAML display modes in markview
4. Consider alternative YAML formatting plugins
5. Custom syntax highlighting for YAML frontmatter

### Issue 3: YAML Folding Intermittent Failure (2026-01-30) ✅ FIXED

**Problem:**
- `<leader>yf>` toggle keybinding intermittently failed with `E350: Cannot create fold with current 'foldmethod'`
- Happened inconsistently: fresh file open → fail, after editing/switching → work

**Root Cause:**
- Toggle function tried to manually create folds with `vim.cmd(fold_start .. "," .. yaml_end .. "fold")`
- This command ONLY works with `foldmethod=manual`, not `foldmethod=expr`
- Line 1228 attempted manual fold creation, incompatible with expression-based folding

**Solution Implemented:**
1. Removed ALL manual fold creation attempts from toggle function
2. Simplified to just toggle `vim.b.yaml_fold_enabled` flag
3. Let fold expression handle actual fold creation
4. Added defensive check for `foldmethod=expr`
5. Clear user notifications about state changes

**File Modified:** `lua/plugins/notes_profile/markdown-enhancements.lua:1179-1226`

**Known Limitations:**
- `zc` (close) and `zo` (open) work perfectly ✅
- `za` (toggle) sometimes fails with E350 - known limitation of `foldmethod=expr`
- User prefers using `zc`/`zo` over `za` anyway

**Status:** ✅ **RESOLVED** - Working consistently across all scenarios

---

## Current Status (January 30, 2026)

### ✅ Working Features
1. **4-State Checkboxes** with NerdFont icons (markview.nvim)
2. **List Indentation** with Tab/Shift-Tab (Insert mode only)
3. **Heading Icons** in closed folds
4. **YAML Frontmatter Folding** (conditional, toggleable) - ✅ **FIXED** (2026-01-30)
5. **Header-Based Folding** (H1-H6 with proper nesting)
6. **List Item Folding** (nested/indented items)
7. **Modular Architecture** (clean separation of concerns)

### ⚠️ Known Issues
1. **YAML Frontmatter Formatting** - icons not displaying in markview (pending)
2. **Treesitter Query File** - patch may be overwritten by updates
3. **`za` command limitation** - sometimes fails with E350 (known `foldmethod=expr` limitation)

### 📋 Next Steps
1. **Fix YAML Frontmatter Formatting** (current exploration - markview icons not displaying)
2. **Phase 12: Workspace Management** (multi-workspace support)
3. **Phase 13+:** Time tracking, export system, text objects, analytics

### 📁 Key Documentation Files
- **NEORG_INSPIRED_ENHANCEMENTS.md** - Comprehensive plan (all phases, detailed specs)
- **PHASE_TRACKER.md** - Working status, recent issues, feature tracking
- **TROUBLESHOOTING_LOG.md** - Treesitter crash resolution
- **SESSION_SUMMARY.md** - This file (overall project summary)

### 🎯 Key Files Modified
- `lua/plugins/base/markview.lua` - New markdown rendering
- `lua/plugins/notes_profile/markdown-enhancements.lua` - Main enhancements (folding, indentation)
- `lua/plugins/base/treesitter.lua` - Treesitter configuration (vim disabled)
- `lua/notes_profile_modules/config.lua` - Centralized configuration
- `lua/notes_profile_modules/checkbox-core.lua` - Checkbox functions

---

## Commit History (Recent)

- `e6af88d` - fix(notes): implement conditional YAML folding and remove code block folding
- `177160a` - docs: add phase tracker for session management
- `0777acc` - docs: create comprehensive Neorg-inspired enhancements plan
- `f293663` - feat(ui): add breadcrumbs to winbar and improve config
- `8c95ad3` - feat(notes): add Pomodoro chimes, Mac Reminders integration, and image rendering

---
