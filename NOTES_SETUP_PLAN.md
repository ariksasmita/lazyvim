# Neovim Note-Taking & Task Management Setup Plan

## 1. Goal

To create a powerful, reliable, and modular Neovim environment for note-taking and task management. This setup will be inspired by the "Obsidian to Neovim" blog post, tailored to your existing configuration, and built upon a foundation that allows you to safely switch between your "original" setup and this new "notes" setup.

**Inspiration:** [Obsidian to Neovim Blog Post](https://linkarzu.com/posts/neovim/obsidian-to-neovim/)

---

## 2. Phase 1: Creating a Modular Foundation (Completed)

**Objective:** The most critical step. We restructured the `plugins/` directory into separate `base/` and `notes_profile/` profiles, allowing the note-taking setup to be toggled on or off easily.

---

## 3. Phase 2: Core Note-Taking Features (Completed)

**Objective:** Implement the essential features for a fluid Markdown note-taking experience. All new files were created inside `notes_profile/`. This included setting up `marksman` for wiki-links and organizing note-taking specific plugins.

**Update:** The `marksman` LSP is configured and provides some functionality. However, disabling specific linting rules via LSP settings has proven unreliable and is currently **abandoned**.

---

## 4. Phase 3: Task Management (Completed)

**Objective:** Build on the existing `todo-comments.lua` with a more powerful, centralized task management system.

**Action Steps:**

1.  **Centralized TODOs View:** We installed the `folke/trouble.nvim` plugin to provide a centralized, navigable list for all `TODO` items, available via the `<leader>xt` keymap.

---

## 5. Phase 4: improvements & System Maintenance (Pending)

**Objective:** Fixes and Ensure the Neovim environment stays up-to-date.

**Action Steps:**

1.  **Fix on open and file select via telscope theme change (Completed)**: Theme does not change on opening a file or selecting a file via telescope. Fix this issue to ensure consistent theming across all actions.
2.  **Keybinding for basic formatting (Completed)**: Add keybindings for bold, italics, underline, strikethrough, code, and code block formatting in markdown files.
3.  **Keybinding for inserting links (Completed)**: Add keybindings to insert markdown links easily.
4.  **Keybinding for inserting checkboxes (Completed)**: Added keybindings to insert markdown checkboxes easily.
5.  **Quick Heading Search (Completed)**: Implemented a keymap to quickly search and navigate to headings within a markdown file.
6.  **Small icon compared to normal text (Pending User Action)**: Icon shown such as checkboxes and headings are smaller than normal text. Fix this issue to ensure icons are visually consistent with surrounding text. Is it terminal or neovim issue? (Requires user to install a different Nerd Font).
7.  **Image Preview in terminal (Completed)**: Implement image preview functionality within the terminal for markdown files, allowing users to view images directly in Neovim. See the blogpost for reference.
8.  **Auto-formatting on Save (Completed)**: Configure `prettier` to automatically format Markdown files when they are saved.
9.  **Update Neovim (Completed)**: Update the Neovim instance to the latest stable version (e.g., 0.12 or newer) to get the latest features and security fixes. This may require checking for and fixing breaking changes.
    [Google Search](https://www.google.com/search?q=how+to+update+neovim+to+latest+version)
    [Antropic Claude](https://chat.anthropic.com/chat?model=claude-2)

---

## 6. Phase 5: Advanced Markdown Features (Completed)

**Objective:** Add quality-of-life improvements for interacting with Markdown files.

**Action Steps:**

1.  **Checkbox Toggling (Completed)**: Implemented a keymap to easily toggle checkboxes (`[ ]` <-> `[x]`).
2.  **Kanban-like List Management (Completed)**: Implemented functionality to move completed checklist items to a "DONE" section within the same file.

---

## 7. Phase 6: YAML Frontmatter Metadata (Completed)

**Objective:** Leverage the Obsidian-style YAML headers in Markdown files for enhanced note management.

**Action Steps:**

1. **YAML Parsing & Display**: Added functions to parse frontmatter and a keymap (`<leader>ym`) to display metadata (title, tags, status, etc.).
2. **Auto-Update Dates**: Automatically update the 'updated' field to today's date on file save.
3. **Metadata Search Functionality**: Implemented search and filtering of notes by YAML frontmatter fields (e.g., status, tags, priority, or custom fields) using Telescope for efficient navigation and organization (via `<leader>ys` keymap).
4. **List Auto-Continuation**: Implemented automatic continuation of unordered (`-`, `*`, `+`) and ordered (`1.`, `2.`, etc.) lists when pressing Enter in insert mode or using o/O in normal mode.

---

## 7. Phase 7: Backlinks System (Completed)

**Objective:** Implement a backlinks system to link notes together, similar to Obsidian.

**Action Steps:**

1. **Telescope Integration**: Created a custom Telescope picker (`<leader>bl`) to search and select Markdown files for linking.
2. **Insert Links**: On selection, inserts a Markdown link `[title](path.md)` at cursor.

---

## 8. Phase 8: Additional Quality-of-Life Improvements (Completed)

**Objective:** Add final enhancements for writing, organization, and searching to polish the notes setup.

**Action Steps:**

1. **Full-Text Search Across Vault**: Implemented a Telescope live_grep picker limited to the notes directory for searching note content (e.g., `<leader>fn` keymap).
2. **Automatic Table of Contents (TOC)**: Implemented functionality to generate a TOC from headings in the current note (e.g., `<leader>toc` inserts a TOC section).
3. **Note Templates Expansion**: Expanded to include meeting note template (via `<leader>yhm` keymap).
4. **Smart Folding for Markdown**: Completed - Implemented comprehensive folding for YAML frontmatter, headers (by heading level), and nested lists/checkboxes for better navigation in long notes.
5. **Improved Metadata Search**: Implemented sorting by updated date (newest first) and enhanced previews (show first 20 lines with truncation) in the metadata picker.
6. **Auto-Formatting on Paste**: Automatically rewrap and format pasted text in Markdown files to maintain clean formatting.
7. **Word/Character Count Display**: Implemented word/character count display (via `<leader>wc` keymap).
8. **Pomodoro Integration with Checkboxes**: Integrate pomo.nvim to start 25m timers on checkbox lines (using sanitized text as title), manually append session markers (` | [*]`, ` | [**]`, etc.) via `<leader>tm` keymap, and provide short (5m) and long (10m) rest timers via `<leader>ts` and `<leader>tl`.

---

## 9. Phase 9: File Organization & Naming (Completed)

**Objective:** Implement automatic file naming convention based on YAML frontmatter for chronological sorting.

**Action Steps:**

1. **Automatic File Renaming**: Implemented auto-rename on first save for new markdown files based on YAML frontmatter (format: `YYYY-MM-DD-title-slug.md`).
2. **Manual Rename Keymap**: Added `<leader>yr` keymap to manually rename existing files based on their YAML frontmatter.
3. **Safe Rename Logic**: Implemented validation to prevent overwriting files, ensure required YAML fields exist, and use stable `created` date for filename.
4. **Title Slug Generation**: Converts titles to URL-friendly format (lowercase, hyphens, no special characters).

---

## 10. Phase 10: Pomodoro & Mac Reminders Integration (Completed)

**Objective:** Enhance Pomodoro timer experience with completion chimes and integrate Mac Reminders for task management from within Neovim.

**Action Steps:**

1. **Pomodoro Completion Chime (Completed)**: Added audio feedback when Pomodoro timers complete.
   - Work sessions (≥20 min): `Glass.aiff` sound
   - Rest sessions (<20 min): `Purr.aiff` sound
   - Uses system volume, no custom volume control
   - Visual notifications with different messages for work/rest
   - **File Modified**: `lua/plugins/base/pomonvim.lua`

2. **Mac Reminders Integration (Completed)**: Create reminders directly from Markdown checkboxes.
   - Annotation format: `@remind(date)` in checkbox text
   - Supports formats: `YYYY-MM-DD`, `YYYY-MM-DD HH:MM`, `today`, `tomorrow`, `next week`
   - Duplicate detection via YAML frontmatter tracking
   - Single reminder creation: `<leader>rc`
   - Bulk sync all reminders: `<leader>rs`
   - Snippet: `remind` + Tab → `@remind(YYYY-MM-DD)`
   - **Files Modified**: 
     - `lua/plugins/notes_profile/markdown-enhancements.lua`
     - `lua/plugins/notes_profile/snippets/markdown/links.lua`

**Testing:**
- Test file created at `/tmp/test_reminders.md`
- Verify single reminder creation with `<leader>rc`
- Verify duplicate detection prevents re-creating reminders
- Verify bulk sync with `<leader>rs`
- Check YAML frontmatter gets `synced_reminders` tracking section

---

## 11. Next Steps

All major features have been implemented! The notes setup is now complete with:
- ✅ Comprehensive markdown folding (YAML, headers, lists)
- ✅ Automatic date-based file naming
- ✅ Full Obsidian-style workflow
- ✅ Task management and Pomodoro integration
- ✅ Pomodoro completion chimes
- ✅ Mac Reminders integration with duplicate detection

Focus on using and refining your workflow. Consider:
- Testing the Mac Reminders integration with real notes
- Using Pomodoro timers with checkbox tasks
- Testing the auto-rename feature on new notes
- Organizing existing notes with `<leader>yr`
- Using folding commands (`za`, `zM`, `zR`) for navigation
- Exploring metadata search (`<leader>ys`) for note discovery

**Potential Future Enhancements:**
- Auto-sync reminders on save (if manual sync feels tedious)
- Two-way sync (mark checkbox complete when reminder is done in Mac Reminders)
- Custom reminder list selection

---

## 12. Keybindings Summary

Here is a summary of the keybindings implemented:

### Task Management
- **`<leader>xt`**: Open Centralized TODOs View (via `trouble.nvim`)

### Checkboxes & Lists
- **`<leader>cx`**: Toggle Markdown Checkbox on current line
- **`<leader>cm`**: Move completed Markdown Checkbox item to `## DONE` section
- **`<leader>ci`**: Insert Markdown Checkbox on a new line below, with indentation, and enter insert mode

### Navigation
- **`<leader>sh`**: Search Headings in current Markdown file (via Telescope LSP Document Symbols)
- **`<leader>fn`**: Full-text search across notes vault (via Telescope live_grep)
- **`za`**: Toggle fold at cursor (YAML/header/list)
- **`zo` / `zc`**: Open / Close fold
- **`zR` / `zM`**: Open / Close ALL folds
- **`zj` / `zk`**: Jump to next/previous fold

### YAML Frontmatter
- **`<leader>ym`**: Display YAML frontmatter metadata
- **`<leader>yh`**: Insert YAML frontmatter manually
- **`<leader>yhm`**: Insert meeting note template
- **`<leader>ys`**: YAML Search (search/filter notes by YAML fields using Telescope)
- **`<leader>yf`**: Toggle YAML frontmatter fold
- **`<leader>yr`**: Rename file based on YAML frontmatter (format: YYYY-MM-DD-title.md)

### Linking & Organization
- **`<leader>bl`**: Insert backlink to another Markdown file (via Telescope)
- **`<leader>toc`**: Generate Table of Contents from headings

### Text Formatting
- **`<leader>mb`**: Markdown Bold (`**text**`) - Normal/Visual mode
- **`<leader>mi`**: Markdown Italic (`*text*`) - Normal/Visual mode
- **`<leader>ms`**: Markdown Strikethrough (`~~text~~`) - Normal/Visual mode
- **`<leader>mc`**: Markdown Inline Code (`` `text` ``) - Normal/Visual mode
- **`<leader>mC`**: Markdown Code Block (` ``` `) - Normal/Visual mode

### Utilities
- **`<leader>wc`**: Show word/character count
- **`<leader>p`**: Paste image from clipboard (saves to `assets/` directory)

### Pomodoro Integration
- **`<leader>tp`**: Start Pomodoro timer on checkbox line (25m) - plays Glass.aiff on completion
- **`<leader>tm`**: Mark Pomodoro session on checkbox line
- **`<leader>ts`**: Start short rest timer (5m) - plays Purr.aiff on completion
- **`<leader>tl`**: Start long rest timer (10m) - plays Purr.aiff on completion

### Mac Reminders Integration
- **`<leader>rc`**: Create Mac reminder from current checkbox line with @remind() annotation
- **`<leader>rs`**: Sync all checkboxes with @remind() annotations to Mac Reminders

### Snippets
- **`link` + `<Tab>`**: Insert Markdown Link `[text](url)` snippet (via `LuaSnip`)
- **`meta` + `<Tab>`**: Insert Obsidian-style YAML frontmatter (via `LuaSnip`)
- **`remind` + `<Tab>`**: Insert `@remind(YYYY-MM-DD)` annotation (via `LuaSnip`)

