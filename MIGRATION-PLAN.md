# Neovim Configuration Migration Plan

 Overview

 Migrate configuration from ~/.config/nvim.neorg (old/backup) to ~/.config/nvim (new/clean) incrementally
 to identify what causes crashes.

 Source: ~/.config/nvim.neorg/
 Target: ~/.config/nvim/

 User preferences:
 - Keep split plugin structure: plugins/base/ + plugins/notes_profile/
 - Priority: Core editing features first
 - Skip notes_profile_modules/ for now

 ---
 Phase 1: Basic Configuration (Safe - Low Risk)

 Step 1.1: Update lazy.lua structure

 File: ~/.config/nvim/lua/config/lazy.lua

 Add:
 - Import plugins.base and plugins.notes_profile
 - Add change_detection.disabled = true (prevents reload crashes)

 Changes:
 spec = {
   { "LazyVim/LazyVim", import = "lazyvim.plugins" },
   { import = "plugins" },  -- or remove this line
   { import = "plugins.base" },
   { import = "plugins.notes_profile" },
 },

 Add change_detection section from old config.

 Test: Open nvim, ensure Lazy loads without errors.

 ---
 Step 1.2: Migrate options.lua

 Source: ~/.config/nvim.neorg/lua/config/options.lua
 Target: ~/.config/nvim/lua/config/options.lua

 Copy all content:
 - vim.g.autoformat = false
 - breakindent settings
 - showbreak configuration

 Test: Open nvim, try editing text.

 ---
 Step 1.3: Migrate keymaps.lua (basic)

 Source: ~/.config/nvim.neorg/lua/config/keymaps.lua
 Target: ~/.config/nvim/lua/config/keymaps.lua

 Copy in stages:

 1.3a - Safe keymaps first:
 - jk/kj insert mode mappings (including TelescopePrompt exclusion)
 - Tab/S-Tab buffer navigation

 Test: Try insert mode jk/kj, try Tab navigation.

 1.3b - Terminal keymaps:
 - <leader>tv (vertical terminal)
 - <leader>th (horizontal terminal)
 - <leader>ts (terminal selector)

 Test: Try opening terminals.

 1.3c - Telescope keymaps:
 - <leader>fs (find files in folder)
 - <leader>fG (grep in folder)

 Test: Try telescope commands.

 ---
 Step 1.4: Migrate autocmds.lua (without paste_image)

 Source: ~/.config/nvim.neorg/lua/config/autocmds.lua
 Target: ~/.config/nvim/lua/config/autocmds.lua

 Copy only the safe parts:
 - pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")
 - FileType autocmd for markdown/text (spell settings, conceallevel)

 DO NOT COPY yet:
 - Paste image autocmd (requires notes_profile_modules)

 Test: Open a markdown file.

 ---
 Phase 2: Essential Base Plugins

 Step 2.1: Create plugin directories

 Create:
 - ~/.config/nvim/lua/plugins/base/
 - ~/.config/nvim/lua/plugins/notes_profile/

 ---
 Step 2.2: Disable noice.nvim

 Source: ~/.config/nvim.neorg/lua/plugins/base/disable-noice.lua
 Target: ~/.config/nvim/lua/plugins/base/disable-noice.lua

 Why: This was critical for fixing E36 crashes.

 Copy entire file.

 Test: Check that notifications work (snacks.nvim notifier).

 ---
 Step 2.3: Telescope configuration

 Source: ~/.config/nvim.neorg/lua/plugins/base/telescope.lua
 Target: ~/.config/nvim/lua/plugins/base/telescope.lua

 Copy entire file (vertical layout, C-j/C-k mappings).

 Test: <Space>sg for search, try C-j/C-k navigation.

 ---
 Step 2.4: Snacks.nvim configuration

 Source: ~/.config/nvim.neorg/lua/plugins/base/snacks.lua
 Target: ~/.config/nvim/lua/plugins/base/snacks.lua

 Copy entire file.

 Test: Terminal commands should work.

 ---
 Step 2.5: Treesitter configuration

 Source: ~/.config/nvim.neorg/lua/plugins/base/treesitter.lua
 Target: ~/.config/nvim/lua/plugins/base/treesitter.lua

 Copy entire file.

 Test: Open various file types, check syntax highlighting.

 ---
 Phase 3: Colorschemes

 Step 3.1: Theme plugins

 Sources:
 - ~/.config/nvim.neorg/lua/plugins/base/moonfly.lua
 - ~/.config/nvim.neorg/lua/plugins/base/github-theme.lua
 - ~/.config/nvim.neorg/lua/plugins/base/markdown-theming.lua

 Targets: Same paths in new config.

 Order:
 1. Copy moonfly.lua first
 2. Test: :colorscheme moonfly
 3. Copy github-theme.lua
 4. Copy markdown-theming.lua (this switches themes based on directory)

 Test: Open files in different directories, check theme switches.

 ---
 Phase 4: Markdown Rendering (High Crash Risk)

 ⚠️ Proceed carefully - these were causing crashes

 Step 4.1: markview.nvim (PROBABLE CRASH CULPRIT)

 Source: ~/.config/nvim.neorg/lua/plugins/base/markview.lua

 Test Strategy:
 1. Copy with enabled = false first
 2. Test nvim opens
 3. Enable and test markdown files

 If crash occurs: Leave disabled, consider using render-markdown.lua instead.

 ---
 Step 4.2: render-markdown.lua

 Source: ~/.config/nvim.neorg/lua/plugins/base/render-markdown.lua

 Note: Already has enabled = false in old config.

 If needed: Enable this as alternative to markview.

 ---
 Step 4.3: image-nvim.lua

 Source: ~/.config/nvim.neorg/lua/plugins/base/image-nvim.lua

 Test Strategy:
 1. Copy with enabled = false
 2. Test opening markdown files
 3. Enable if needed for image support

 ---
 Step 4.4: Markdown theming autocmds

 Source: ~/.config/nvim.neorg/lua/plugins/base/markdown-theming.lua

 Risk: BufEnter autocmd on all buffers could cause issues.

 Test: Copy and test opening various file types.

 ---
 Phase 5: UI Improvements

 Step 5.1: Breadcrumbs/winbar

 Source: ~/.config/nvim.neorg/lua/plugins/base/breadcrumbs-winbar.lua
 Target: ~/.config/nvim/lua/plugins/base/breadcrumbs-winbar.lua

 Test: Open code files, check breadcrumbs appear at top.

 ---
 Step 5.2: Lualine customization

 Source: ~/.config/nvim.neorg/lua/plugins/base/lualine-no-breadcrumbs.lua

 Test: Check statusline appearance.

 ---
 Phase 6: Additional Base Plugins

 Step 6.1: Quality of Life plugins

 Sources:
 - todo-comments.lua
 - linting.lua
 - toppair-peek-md.lua
 - pomonvim.lua
 - setup.lua
 - search-fix.lua (if still needed)
 - example.lua (likely can skip)

 Strategy: Copy one at a time, test after each.

 ---
 Phase 7: Notes Profile Plugins

 Step 7.1: Conform (formatter)

 Source: ~/.config/nvim.neorg/lua/plugins/notes_profile/conform.lua
 Target: ~/.config/nvim/lua/plugins/notes_profile/conform.lua

 Test: Format code files.

 ---
 Step 7.2: Trouble (diagnostics)

 Source: ~/.config/nvim.neorg/lua/plugins/notes_profile/trouble.lua

 Test: <Space>xd to open trouble.

 ---
 Step 7.3: Marksman lint config

 Source: ~/.config/nvim.neorg/lua/plugins/notes_profile/marksman-lint-config.lua

 Test: Open markdown file, check linting.

 ---
 Step 7.4: Headlines

 Source: ~/.config/nvim.neorg/lua/plugins/notes_profile/headlines.lua

 Note: Already disabled in old config (conflicts with markview).

 Test: Enable if not using markview.

 ---
 Step 7.5: Markdown enhancements

 Source: ~/.config/nvim.neorg/lua/plugins/notes_profile/markdown-enhancements.lua

 ⚠️ HIGH RISK - 1392 lines, heavy customization

 Test Strategy:
 1. Copy with enabled = false
 2. Check if nvim loads
 3. Enable incrementally by commenting out sections

 If crash: Need to debug which feature causes crash.

 ---
 Step 7.6: Snippets

 Source: ~/.config/nvim.neorg/lua/plugins/notes_profile/snippets/markdown/links.lua
 Target: ~/.config/nvim/lua/plugins/notes_profile/snippets/markdown/links.lua

 Test: Try markdown snippet expansion.

 ---
 Post-Migration: Autocmds Fix

 Step 8.1: Add paste_image autocmd (if modules migrated later)

 Only add this if/when notes_profile_modules/ is migrated:

 Update ~/.config/nvim/lua/config/autocmds.lua:
 vim.api.nvim_create_autocmd("FileType", {
   pattern = "markdown",
   callback = function()
     local paste_image = require("notes_profile_modules.local-paste-image")
     vim.keymap.set({ "n" }, "<leader>p", paste_image.paste_image, {
       desc = "Paste Image from Clipboard",
       buffer = 0,
     })
   end,
 })

 ---
 Testing Checklist

 After each phase, test:
 - nvim opens without crashing
 - Can open lua files
 - Can open markdown files (the crash test case)
 - Search works (<Space>sg)
 - Terminal works
 - Insert mode jk/kj works

 ---
 Troubleshooting

 If markdown files crash:

 1. Disable markview.lua: enabled = false
 2. Disable markdown-theming.lua
 3. Disable image-nvim.lua
 4. Re-enable one at a time to find culprit

 If search crashes:

 1. Check snacks.lua grep configuration
 2. Check telescope.lua configuration
 3. Disable search-fix.lua if present

 If general crashes:

 1. Check ~/.local/state/nvim/noice.log
 2. Check Lazy sync: :Lazy sync
 3. Try headless mode: nvim --headless +"e test.md" +"qa"

 ---
 Files to Copy (Quick Reference)

 Core Config

 - lua/config/lazy.lua
 - lua/config/options.lua
 - lua/config/keymaps.lua
 - lua/config/autocmds.lua

 Base Plugins

 - lua/plugins/base/disable-noice.lua
 - lua/plugins/base/telescope.lua
 - lua/plugins/base/snacks.lua
 - lua/plugins/base/treesitter.lua
 - lua/plugins/base/moonfly.lua
 - lua/plugins/base/github-theme.lua
 - lua/plugins/base/markdown-theming.lua
 - lua/plugins/base/markview.lua ⚠️
 - lua/plugins/base/render-markdown.lua
 - lua/plugins/base/image-nvim.lua ⚠️
 - lua/plugins/base/breadcrumbs-winbar.lua
 - lua/plugins/base/lualine-no-breadcrumbs.lua
 - lua/plugins/base/todo-comments.lua
 - lua/plugins/base/linting.lua
 - lua/plugins/base/toppair-peek-md.lua
 - lua/plugins/base/pomonvim.lua
 - lua/plugins/base/setup.lua

 Notes Profile Plugins

 - lua/plugins/notes_profile/conform.lua
 - lua/plugins/notes_profile/trouble.lua
 - lua/plugins/notes_profile/marksman-lint-config.lua
 - lua/plugins/notes_profile/headlines.lua
 - lua/plugins/notes_profile/markdown-enhancements.lua ⚠️
 - lua/plugins/notes_profile/snippets/markdown/links.lua

 Skipped (for now)

 - lua/notes_profile_modules/ (entire directory)
