# Neovim Configuration - Agent Context

## Project Overview

This is a LazyVim-based Neovim configuration located at `~/.config/nvim/`. The configuration is currently in migration from an older setup at `~/.config/nvim.neorg/` to a cleaner, more stable version.

## Base Configuration

### Structure
- **Framework**: LazyVim starter template
- **Plugin Manager**: lazy.nvim
- **Entry Point**: `init.lua` → `require("config.lazy")`
- **Key Directories**:
  - `lua/config/` - Core configuration (lazy.lua, options.lua, keymaps.lua, autocmds.lua)
  - `lua/plugins/base/` - Base plugins for all editing needs
  - `lua/plugins/notes_profile/` - Markdown/note-taking specific plugins
  - `lua/notes_profile_modules/` - Custom Lua modules for notes functionality
  - `llmcontext/` - Session logs and tracking documentation

### Critical Settings
- `change_detection.enabled = false` - Prevents reload crashes
- Plugin loading order: LazyVim → plugins.base → plugins.notes_profile
- Split plugin structure maintains base vs notes profile separation

## Known Issues & Migration Status

### Migration in Progress
The config is being migrated incrementally from `~/.config/nvim.neorg/` to avoid crashes. See `MIGRATION-PLAN.md` for detailed phases.

### High-Risk Plugins (Crash Culprits)
- `markview.lua` - PROBABLE crash culprit (markdown rendering)
- `markdown-enhancements.lua` - 1392 lines, heavy customization
- `image-nvim.lua` - Image support for markdown

### Disabled Plugins
- `noice.nvim` - Disabled via `disable-noice.lua` (critical for fixing E36 crashes)
- `headlines.lua` - Conflicts with markview, currently disabled
- Various plugins kept at `enabled = false` for stability

## Plugin Architecture

### Base Plugins (`lua/plugins/base/`)
- **pi.nvim** - Enhanced AI assistant integration with full CLI context
  - `<leader>ai` - Quick ask (buffer/selection)
  - `<leader>aif` - Floating terminal with buffer context
  - `<leader>aip` - Floating terminal with full project context (AGENTS.md, skills, tools)
  - `<leader>aic` - Cancel request, `<leader>ail` - View log
  - See `PI_INTEGRATION.md` for detailed usage
- **Telescope**: Custom vertical layout, C-j/C-k navigation
- **Telescope**: Custom vertical layout, C-j/C-k navigation
- **Snacks.nvim**: Terminal handling (tv/th/ts commands)
- **Treesitter**: Syntax highlighting configuration
- **Colorschemes**: moonfly, github-theme with directory-based switching
- **Markdown Rendering**: markview, render-markdown (careful with enabling)
- **UI Elements**: breadcrumbs-winbar, custom lualine
- **Utilities**: todo-comments, linting, pomonvim timer
- **Critical**: disable-noice.lua (prevents crashes)

### Notes Profile Plugins (`lua/plugins/notes_profile/`)
- **Conform**: Code formatter
- **Trouble**: Diagnostics viewer (<leader>xd)
- **Marksman**: Markdown linting configuration
- **Headlines**: Currently disabled
- **Markdown Enhancements**: Heavy customization (enable carefully)
- **Snippets**: Custom markdown link snippets

### Notes Profile Modules (`lua/notes_profile_modules/`)
- `markdown-foldtext.lua` - Custom markdown folding
- `config.lua` - Notes profile configuration
- `checkbox-core.lua` - Checkbox functionality
- `workspace.lua` - Workspace management
- `reminders.lua` - Reminder system
- `local-paste-image.lua` - Paste image from clipboard
- `navigation.lua` - Navigation utilities

### Special Files
- `fix-notion-table.lua` - Notion table fixes
- `copilot.lua` - GitHub Copilot configuration

## Key Behaviors

### Insert Mode
- `jk` / `kj` → Exit insert mode (excludes TelescopePrompt)
- Clipboard paste image: `<leader>p` (markdown files only)

### Terminal
- `<leader>tv` → Vertical terminal
- `<leader>th` → Horizontal terminal
- `<leader>ts` → Terminal selector

### Telescope
- `<leader>fs` → Find files in folder
- `<leader>fG` → Grep in folder
- `<leader>sg` → Live grep (via Snacks)

### Theme Switching
Directory-based theme switching via `markdown-theming.lua`

## Testing Rules

When making changes:
1. Test nvim opens without crashing
2. Test opening markdown files (crash test case)
3. Test search functionality
4. Test terminal commands
5. Test insert mode jk/kj mappings

## File Organization for Edits

### Safe to Edit
- `lua/config/options.lua` - Editor options
- `lua/config/keymaps.lua` - Key mappings
- `lua/config/autocmds.lua` - Auto commands
- Base plugins (one at a time, test after each)

### High Risk - Edit Carefully
- `lua/plugins/base/markview.lua`
- `lua/plugins/base/markdown-enhancements.lua`
- `lua/plugins/base/image-nvim.lua`
- Theme-related files with autocmds

### Never Modify Without Backup
- `lua/config/lazy.lua` - Core bootstrap
- `lua/plugins/base/disable-noice.lua` - Critical crash fix

## Session Context

The `llmcontext/` directory contains session logs tracking configuration work:
- `PHASE_TRACKER.md` - Migration progress tracking
- `BREADCRUMBS_WINBAR_LOG.md` - Breadcrumbs feature work
- `TROUBLESHOOTING_LOG.md` - Issue tracking
- Session files - Historical context for specific tasks

## Environment Specifics

- **Path**: `~/.config/nvim/`
- **Backup Path**: `~/.config/nvim.neorg/`
- **Plugin Lock**: `lazy-lock.json` (commit for reproducibility)
- **Config Files**: `.neoconf.json`, `stylua.toml`
- **Lazy Config**: `lazyvim.json`

## Critical Commands

- `:Lazy sync` - Update plugins
- `:Lazy health` - Check plugin health
- `nvim --headless +"e test.md" +"qa"` - Headless crash testing
- Check `~/.local/state/nvim/noice.log` for crash debugging

## Dependencies

- Neovim 0.9+ (LazyVim requirement)
- Git (for lazy.nvim)
- Optional: clipboard tool for image paste functionality