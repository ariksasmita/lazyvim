# Breadcrumbs to Winbar Configuration Log

## Date: Tue Dec 30 2025

## Objective
Move breadcrumbs (code structure navigation) from statusline to winbar (top of window, under buffer tabs)

## Current Setup
- Using `nvim-navic` plugin for breadcrumbs in `/Users/sasmitai/.config/nvim/lua/plugins/base/setup.lua`
- Currently displaying in statusline (bottom bar)
- LazyVim default configuration

## Changes Required
1. Configure `winbar` to display breadcrumbs at the top
2. Remove breadcrumbs from statusline if present
3. Ensure breadcrumbs appear below buffer tabs in split windows

## Implementation Steps
- [x] Create winbar configuration in `breadcrumbs-winbar.lua`
- [x] Move navic config from setup.lua to dedicated file
- [ ] Test breadcrumbs display (user to verify)
- [ ] Verify positioning under buffer tabs (user to verify)

## Files Modified
1. **Created**: `lua/plugins/base/breadcrumbs-winbar.lua`
   - Configured nvim-navic to display in winbar
   - Set up autocmds for CursorMoved, BufWinEnter, BufFilePost
   - Winbar format: `%{%v:lua.require'nvim-navic'.get_location()%}`
   - Fixed: Changed `navic.attach()` to `require("nvim-navic").attach()` to fix nil value error

2. **Created**: `lua/plugins/base/lualine-no-breadcrumbs.lua`
   - Override LazyVim's default lualine configuration
   - Remove breadcrumbs from statusline (lualine_c section)
   - Show only filetype icon and filename in statusline

3. **Modified**: `lua/plugins/base/setup.lua`
   - Removed nvim-navic configuration (moved to breadcrumbs-winbar.lua)
   - Added comment indicating new location

## Troubleshooting Done
- **Issue 1**: `attempt to index global 'navic' (a nil value)` - Fixed by using `require("nvim-navic")` instead of bare `navic`
- **Issue 2**: Breadcrumbs still showing in bottom statusbar - Fixed by overriding lualine_c section to remove breadcrumb component
- **Issue 3**: Top bar showing grey only - Added filename display and linked WinBar highlight to StatusLine for visibility
- **Issue 4**: `E36 Not enough room` / blink.cmp window error - Added window height check (min 4 lines) and filetype exclusions to prevent winbar in small windows or special buffers
- **Issue 5**: Telescope preview and snacks explorer showing winbar - Added buftype check (skip all special buffer types), added TelescopePrompt/Results and snacks filetypes to ignore list, added unnamed/scratch buffer detection
- **Issue 6**: Filename redundant and showing full path - Removed filename from winbar completely, only show breadcrumbs when available (otherwise no winbar)
- **Issue 7**: Winbar color different from statusline - Changed highlight from `WinBarNC` to `StatusLine` to match bottom bar exactly
- **Issue 8**: Slow/laggy breadcrumb updates - Added 100ms debounce throttling on CursorMoved events, immediate update only for BufWinEnter/BufFilePost/LspAttach events
- **Issue 9**: Winbar still not matching lualine color exactly - Now dynamically reads `lualine_c_normal` highlight and creates matching `WinBarCustom` highlight with same bg/fg
- **Issue 10**: Breadcrumbs missing after telescope file selection or session restore - Added BufReadPost and SessionLoadPost autocmds with 200ms delay to allow LSP to attach first
- **Issue 11**: Color changes when breadcrumbs appear - Navic uses its own highlight groups. Disabled navic's highlight option and override ALL navic highlight groups (NavicIcons*, NavicText, NavicSeparator) to match lualine colors
- **Issue 12**: First buffer in session restore doesn't show breadcrumbs - Added dedicated SessionLoadPost handler that iterates through all visible windows and updates each one after 1000ms delay

## Performance Optimizations
- Throttled CursorMoved event with 100ms debounce
- Only immediate updates on file open or LSP attach
- Reduced unnecessary winbar recalculations
- Session/telescope files get delayed update (200ms, 500ms) to wait for LSP

## How It Works
- Winbar is window-local, appears at top of each split window
- Will show below buffer tabs (tabline) when present
- Uses `nvim-navic` API: `require("nvim-navic").get_location()`
- Only displays when LSP navic data is available
- Updates on cursor movement and buffer events

## Notes
- Breadcrumbs now separate from filename and git branch (statusline)
- Each window split will show its own breadcrumb trail
- If no LSP symbols available, winbar won't show
