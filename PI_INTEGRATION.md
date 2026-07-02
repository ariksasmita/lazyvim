# Pi CLI Integration in Neovim

This plugin provides two levels of pi CLI integration in Neovim:

## Quick Commands (pi.nvim built-in)

For quick questions without leaving your workflow:

- `<leader>ai` (normal) - Ask pi about current buffer
- `<leader>ai` (visual) - Ask pi about selected text
- `<leader>aic` - Cancel active pi request
- `<leader>ail` - Open pi session log

## Full CLI Experience (floating terminal)

For complete pi CLI capabilities with full codebase context:

### `<leader>aif` - Pi with Buffer Context
- Opens pi in floating terminal with current buffer content as context
- In visual mode: uses selected text instead
- Pi has read/write/edit/bash tools to modify files
- Changes are reflected when you close the floating window

### `<leader>aip` - Pi with Project Context
- Opens pi in floating terminal with full project awareness
- Automatically discovers and uses:
  - `AGENTS.md` and `CLAUDE.md` for project context
  - All enabled skills (databases, react, vue, etc.)
  - Extensions (9router, stitch, subagent)
  - Project structure and file relationships
- Full access to pi's tools: read, write, edit, bash
- Can make complex multi-file changes with full context

## Commands

- `:PiFloat` - Same as `<leader>aif`, prompts for input
- `:PiProject` - Same as `<leader>aip`, prompts for input

## Use Cases

**Quick Questions:**
```
<leader>ai> "What does this function do?"
<leader>ai> "Explain this error"
```

**Code Refactoring (with buffer context):**
```
<leader>aif> "Refactor this function to use async/await"
<leader>aif> "Add error handling to this class"
```

**Project-Wide Changes (with full context):**
```
<leader>aip> "Add logging to all API endpoints"
<leader>aip> "Migrate from Redux to Zustand step by step"
<leader>aip> "Set up unit tests for the authentication module"
```

**Complex Tasks Requiring Multiple Files:**
```
<leader>aip> "Create a new REST API endpoint for user management with proper validation, error handling, and tests"
```

## Navigation in Floating Terminal

- `ESC` - Exit terminal mode to normal mode
- `q` - Close floating window (works in both terminal and normal mode)
- `Ctrl+q` - Alternative close command
- Normal terminal commands work as expected

**To close the window:** Press `q` (if in terminal mode) or `ESC` then `q` (if in normal mode)

## File Modification

Pi can directly modify files using its tools. When pi edits files:
- Changes are made to the actual files on disk
- Neovim will detect changes when you switch back to the buffer
- Use `:e` to reload if needed

## Key Differences

| Feature | `<leader>ai` | `<leader>aif` | `<leader>aip` |
|---------|-------------|---------------|---------------|
| Speed | Fast | Medium | Medium |
| Context | Buffer | Buffer file | Full project |
| Skills/Extensions | Basic | Full | Full |
| File Modification | Limited | Full | Full |
| Best For | Quick questions | Single-file edits | Complex multi-file tasks |

## Configuration

The plugin is configured in `lua/plugins/base/pi.lua`:
- Provider: 9router
- Model: cx/gpt-5.3-codex
- Skills and extensions enabled
- Larger context window for better awareness

Modify the `opts` table to change provider, model, or other settings.