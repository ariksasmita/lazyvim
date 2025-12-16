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

1.  **Fix on open and file select via telscope theme change**: Theme does not change on opening a file or selecting a file via telescope. Fix this issue to ensure consistent theming across all actions.
2.  **Keybinding for basic formatting (Completed)**: Add keybindings for bold, italics, underline, strikethrough, code, and code block formatting in markdown files.
3.  **Keybinding for inserting links (Completed)**: Add keybindings to insert markdown links easily.
4.  **Keybinding for inserting checkboxes (Completed)**: Added keybindings to insert markdown checkboxes easily.
5.  **Quick Heading Search (Completed)**: Implemented a keymap to quickly search and navigate to headings within a markdown file.
6.  **Small icon compared to normal text (Pending User Action)**: Icon shown such as checkboxes and headings are smaller than normal text. Fix this issue to ensure icons are visually consistent with surrounding text. Is it terminal or neovim issue? (Requires user to install a different Nerd Font).
7.  **Image Preview in terminal**: Implement image preview functionality within the terminal for markdown files, allowing users to view images directly in Neovim. See the blogpost for reference.
8.  **Auto-formatting on Save (Completed)**: Configure `prettier` to automatically format Markdown files when they are saved.
9.  **Update Neovim:** Update the Neovim instance to the latest stable version (e.g., 0.12 or newer) to get the latest features and security fixes. This may require checking for and fixing breaking changes.
[Google Search](https://www.google.com/search?q=how+to+update+neovim+to+latest+version)
[Antropic Claude](https://chat.anthropic.com/chat?model=claude-2)

---

## 6. Phase 5: Advanced Markdown Features (Completed)

**Objective:** Add quality-of-life improvements for interacting with Markdown files.

**Action Steps:**

1.  **Checkbox Toggling (Completed)**: Implemented a keymap to easily toggle checkboxes (`[ ]` <-> `[x]`).
2.  **Kanban-like List Management (Completed)**: Implemented functionality to move completed checklist items to a "DONE" section within the same file.

---

## 7. Next Steps

This plan provides our roadmap. We will now focus on the remaining tasks in **Phase 4**.

---

## 8. Keybindings Summary

Here is a summary of the keybindings implemented so far:

*   **`<leader>xt`**: Open Centralized TODOs View (via `trouble.nvim`)
*   **`<leader>cx`**: Toggle Markdown Checkbox on current line
*   **`<leader>cm`**: Move completed Markdown Checkbox item to `## DONE` section
*   **`<leader>ci`**: Insert Markdown Checkbox on a new line below, with indentation, and enter insert mode
*   **`<leader>sh`**: Search Headings in current Markdown file (via Telescope LSP Document Symbols)
*   **`link` + `<Tab>`**: Insert Markdown Link `[text](url)` snippet (via `LuaSnip`)
*   **`<leader>mb`**: Markdown Bold (`**text**`) - Normal/Visual mode
*   **`<leader>mi`**: Markdown Italic (`*text*`) - Normal/Visual mode
*   **`<leader>ms`**: Markdown Strikethrough (`~~text~~`) - Normal/Visual mode
*   **`<leader>mc`**: Markdown Inline Code (`` `text` ``) - Normal/Visual mode
*   **`<leader>mC`**: Markdown Code Block (` ``` `) - Normal/Visual mode
