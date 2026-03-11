# Web Development Setup Plan

## 1. Goal

Enhance the existing LazyVim-based Neovim configuration with comprehensive support for JavaScript, Vue.js, and modern web development workflows. This will add LSP servers, linting, formatting, testing, debugging, and web-specific tooling while maintaining the modular structure of `base/` and `notes_profile/`.

---

## 2. Phase 0: Foundation & Treesitter Parsers (Not Started)

**Priority:** CRITICAL | **Complexity:** Low | **Estimated Time:** 15 min

**Objective:** Ensure proper syntax highlighting and parsing for all web development languages.

**Action Steps:**

1. **Update Treesitter Configuration** in `lua/plugins/base/treesitter.lua`:
   - Add web-specific parsers to `ensure_installed` list:
     - `javascript`
     - `typescript`
     - `tsx`
     - `vue`
     - `json`
     - `jsonc`
     - `html`
     - `css`
     - `scss`
     - `graphql` (if using GraphQL)

2. **Testing:**
   - Open a `.vue`, `.ts`, `.tsx`, `.js`, and `.css` file
   - Verify syntax highlighting works correctly
   - Run `:checkhealth treesitter` to confirm no errors

---

## 3. Phase 1: LSP Configuration for Web Development (Not Started)

**Priority:** CRITICAL | **Complexity:** Medium | **Estimated Time:** 30 min

**Objective:** Set up language servers for intelligent code completion, diagnostics, and navigation.

**Action Steps:**

1. **Create `lua/plugins/web/lsp.lua`** with LSP configurations:
   - **Volar** (Vue Language Server) for `.vue` files
   - **TypeScript Language Server** for `.ts` and `.tsx` files
   - **ESLint Language Server** for linting integration
   - **CSS Language Server** for CSS/SCSS
   - **HTML Language Server** for HTML

2. **Configuration Details:**

   ```lua
   return {
     {
       "neovim/nvim-lspconfig",
       opts = {
         servers = {
           volar = {},
           ts_ls = {},
           eslint = {
             settings = {
               validate = "on",
             },
           },
           cssls = {},
           html = {},
         },
       },
     },
   }
   ```

3. **Install LSP Servers:**
   - These should auto-install via Mason when you open the relevant filetypes
   - Manual install via `:MasonInstall vue-language-server typescript-language-server eslint-lsp css-lsp html-lsp`

4. **Testing:**
   - Create a test Vue component and verify LSP attaches (`:LspInfo`)
   - Test Go to Definition (`gd`)
   - Test Hover documentation (`K`)
   - Test code completion in insert mode

---

## 4. Phase 2: Auto-Formatting Configuration (Not Started)

**Priority:** HIGH | **Complexity:** Low | **Estimated Time:** 15 min

**Objective:** Extend Prettier configuration to handle all web development filetypes.

**Action Steps:**

1. **Update `lua/plugins/notes_profile/conform.lua`**:
   - Expand `formatters_by_ft` section:
   ```lua
   formatters_by_ft = {
     markdown = { "prettier" },
     javascript = { "prettier" },
     javascriptreact = { "prettier" },
     typescript = { "prettier" },
     typescriptreact = { "prettier" },
     vue = { "prettier" },
     json = { "prettier" },
     jsonc = { "prettier" },
     html = { "prettier" },
     css = { "prettier" },
     scss = { "prettier" },
   }
   ```

2. **Configure Prettier Options** (optional):
   - Add project-specific `.prettierrc` support
   - Configure trailing commas, semicolons, quote style based on project

3. **Testing:**
   - Create test files in each format
   - Use `<leader>fm` to format manually
   - Save file and verify auto-format (if enabled)

---

## 5. Phase 3: Linting Configuration (Not Started)

**Priority:** HIGH | **Complexity:** Medium | **Estimated Time:** 30 min

**Objective:** Integrate ESLint for real-time code quality feedback.

**Action Steps:**

1. **Update `lua/plugins/base/linting.lua`**:
   ```lua
   return {
     {
       "mfussenegger/nvim-lint",
       opts = {
         linters = {
           ["markdownlint-cli2"] = {
             args = { "--config", vim.fn.expand("~/.config/nvim/.markdownlint.json"), "--" },
           },
           eslint = {
             condition = function(ctx)
               return vim.fs.find(
                 { "eslint.config.js", "eslint.config.mjs", ".eslintrc", ".eslintrc.js", ".eslintrc.json" },
                 { path = ctx.filename, upward = true }
               )[1]
             end,
           },
         },
       },
     },
   }
   ```

2. **Project Detection Logic:**
   - Only run ESLint when config file is found in project
   - Supports both new `eslint.config.js` and legacy `.eslintrc` formats

3. **Testing:**
   - Create a project with `eslint.config.js`
   - Create a JS file with linting errors (unused vars, missing semicolons, etc.)
   - Verify diagnostics appear in the editor
   - Check that linting doesn't run in non-ESLint projects

---

## 6. Phase 4: Testing Integration (Not Started)

**Priority:** MEDIUM | **Complexity:** Medium | **Estimated Time:** 45 min

**Objective:** Add the ability to run tests directly from Neovim.

**Action Steps:**

1. **Create `lua/plugins/web/testing.lua`**:
   - Install `vim-test` plugin
   - Configure test runners:
     - Jest for JavaScript/Vue projects
     - Vitest (if using Vitest)
     - Cypress/E2E tests (optional)

2. **Configuration:**

   ```lua
   return {
     {
       "vim-test/vim-test",
       dependencies = {
         "preservim/vimux", -- For running tests in tmux (optional)
       },
       config = function()
         vim.g["test#javascript#runner"] = "jest"
         vim.g["test#javascript#jest#executable"] = "npm test"
         vim.g["test#javascript#jest#options"] = "--coverage=false"

         -- Keymaps
         vim.keymap.set("n", "<leader>tn", ":TestNearest<CR>", { desc = "Run nearest test" })
         vim.keymap.set("n", "<leader>tf", ":TestFile<CR>", { desc = "Run all tests in file" })
         vim.keymap.set("n", "<leader>ts", ":TestSuite<CR>", { desc = "Run entire test suite" })
         vim.keymap.set("n", "<leader>tv", ":TestVisit<CR>", { desc = "Visit last test file" })
         vim.keymap.set("n", "<leader>tl", ":TestLast<CR>", { desc = "Run last test" })
       end,
     },
   }
   ```

3. **Testing:**
   - Create a simple Jest test file
   - Run nearest test (`<leader>tn`)
   - Run all tests in file (`<leader>tf`)
   - Verify test output appears correctly

---

## 7. Phase 5: Debugging Configuration (Not Started)

**Priority:** MEDIUM | **Complexity:** High | **Estimated Time:** 60 min

**Objective:** Add debugging capabilities for JavaScript/Vue applications.

**Action Steps:**

1. **Create `lua/plugins/web/debugging.lua`**:
   - Install `nvim-dap` (Debug Adapter Protocol)
   - Install `nvim-dap-ui` for debugging UI
   - Install JavaScript/Vue debug adapters

2. **Configuration:**

   ```lua
   return {
     {
       "mfussenegger/nvim-dap",
       dependencies = {
         "rcarriga/nvim-dap-ui",
         "theHamsta/nvim-dap-virtual-text",
         "mxsdev/nvim-dap-adapter",
       },
       config = function()
         local dap = require("dap")
         local dapui = require("dapui")

         -- Setup DAP UI
         dapui.setup()

         -- JavaScript/Vue debugger
         dap.adapters.jdtls = {
           type = 'executable',
           command = 'node',
           args = { vim.fn.stdpath("data") .. '/mason/bin/debugserver-adapter' },
         }

         dap.configurations.typescript = {
           {
             type = 'node2',
             request = 'launch',
             name = 'Launch current file',
             cwd = vim.fn.getcwd(),
             args = { '${file}' },
           },
         }

         -- Keymaps
         vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
         vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
         vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
         vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
         vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
         vim.keymap.set("n", "<leader>B", dap.set_breakpoint, { desc = "Debug: Set Breakpoint" })
         vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
       end,
     },
   }
   ```

3. **Install Debug Adapters:**
   - `:MasonInstall js-debug-adapter`

4. **Testing:**
   - Set a breakpoint in a JavaScript file
   - Start debugging (`<F5>`)
   - Verify breakpoints hit correctly
   - Test stepping through code

---

## 8. Phase 6: Better Code Folding (Not Started)

**Priority:** LOW | **Complexity:** Low | **Estimated Time:** 20 min

**Objective:** Improve code folding for JavaScript/TypeScript/Vue files.

**Action Steps:**

1. **Create `lua/plugins/web/folding.lua`**:
   - Install `nvim-ufo` (Ultimate Folding)
   - Configure Treesitter-based folding for web languages

2. **Configuration:**

   ```lua
   return {
     {
       "kevinhwang91/nvim-ufo",
       dependencies = {
         "kevinhwang91/promise-async",
       },
       config = function()
         vim.o.foldcolumn = "1"
         vim.o.foldlevel = 99
         vim.o.foldlevelstart = 99
         vim.o.foldenable = true

         -- Keymaps
         vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
         vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
       end,
     },
   }
   ```

3. **Testing:**
   - Open a large Vue/TS file
   - Verify code folds correctly based on functions/classes/imports
   - Test fold navigation

---

## 9: Phase 7: Enhanced LSP Features (Not Started)

**Priority:** MEDIUM | **Complexity:** Low | **Estimated Time:** 25 min

**Objective:** Add quality-of-life improvements for LSP navigation.

**Action Steps:**

1. **Create `lua/plugins/web/lsp-features.lua`**:
   - Install `nvim-lsp-inlayhints` for inline type hints
   - Install `goto-preview` for peeking definitions without opening files
   - Install `actions-preview.nvim` for code action preview

2. **Configuration:**

   ```lua
   return {
     -- Inlay Hints
     {
       "lvimuser/lsp-inlayhints.nvim",
       config = function()
         require("lsp-inlayhints").setup()
       end,
     },

     -- Goto Preview
     {
       "rmagatti/goto-preview",
       config = function()
         require("goto-preview").setup({
           default_mappings = true,
         })
       end,
     },
   }
   ```

3. **Testing:**
   - Type some TypeScript code and verify inlay hints appear
   - Use `gpd` to preview definition
   - Try code actions with `v:lua.R_ACTION_MENU`

---

## 10. Phase 8: Package.json Scripts Integration (Not Started)

**Priority:** LOW | **Complexity:** Low | **Estimated Time:** 20 min

**Objective:** Easily run npm/yarn/pnpm scripts from package.json.

**Action Steps:**

1. **Create `lua/plugins/web/package-scripts.lua`**:
   - Install `vinnymeller/npm-run.nvim` or create custom Telescope picker

2. **Configuration:**

   ```lua
   return {
     {
       "vinnymeller/npm-run.nvim",
       cmd = { "NpmRun", "NpmRunToggle", "NpmRunUser" },
       config = function()
         require("npm-run").setup({
           notifications = true,
           output_format = "plain",
         })
       end,
     },
   }
   ```

3. **Testing:**
   - Open a project with package.json
   - Run `:NpmRun`
   - Execute common scripts (dev, build, test, lint)

---

## 11. Phase 9: Vue-Specific Enhancements (Not Started)

**Priority:** MEDIUM | **Complexity:** Medium | **Estimated Time:** 30 min

**Objective:** Add Vue.js-specific tooling and quality-of-life improvements.

**Action Steps:**

1. **Create `lua/plugins/web/vue.lua`**:
   - Install `nvim-ts-autotag` for auto-closing HTML/Vue tags
   - Configure Volar for maximum Vue 3 + TypeScript support
   - Add Vue component snippets

2. **Configuration:**

   ```lua
   return {
     -- Auto-close tags
     {
       "windwp/nvim-ts-autotag",
       dependencies = {
         "nvim-treesitter/nvim-treesitter",
       },
       ft = { "html", "javascript", "typescript", "vue", "svelte" },
       config = function()
         require("nvim-ts-autotag").setup()
       end,
     },

     -- Vue snippets
     {
       "rafamadriz/friendly-snippets",
       dependencies = {
         "hrsh7th/nvim-cmp",
       },
     },
   }
   ```

3. **Testing:**
   - Create a Vue SFC (Single File Component)
   - Type `<script>` and verify auto-closing
   - Test template tag autocompletion
   - Test Vue-specific snippets (`vfor`, `vif`, `vcomp`, etc.)

---

## 12. Quick Reference

### File Structure

```
lua/plugins/
├── base/                    # Existing base plugins
│   ├── treesitter.lua      # ✅ UPDATE: Add web parsers
│   ├── linting.lua         # ✅ UPDATE: Add ESLint
│   └── ...
├── notes_profile/           # Existing notes plugins
│   └── conform.lua         # ✅ UPDATE: Add web formatters
└── web/                     # NEW: Web development plugins
    ├── lsp.lua             # LSP configuration for web
    ├── testing.lua         # Test runner integration
    ├── debugging.lua       # DAP debugging setup
    ├── folding.lua         # Enhanced code folding
    ├── lsp-features.lua    # LSP quality-of-life features
    ├── package-scripts.lua # npm/yarn scripts
    └── vue.lua             # Vue-specific enhancements
```

### Required Mason Installations

```bash
# LSP Servers
:MasonInstall vue-language-server typescript-language-server eslint-lsp css-lsp html-lsp

# Debug Adapters
:MasonInstall js-debug-adapter

# Formatters
:MasonInstall prettier prettierd stylua

# Linters
:MasonInstall eslint_d markdownlint-cli2

# (Optional) Additional Tools
:MasonInstall node-debug2-adapter cspell markdown-toc
```

### Keybindings Summary

#### Testing (vim-test)
- **`<leader>tn`**: Run nearest test
- **`<leader>tf`**: Run all tests in file
- **`<leader>ts`**: Run entire test suite
- **`<leader>tv`**: Visit last test file
- **`<leader>tl`**: Run last test

#### Debugging (nvim-dap)
- **`<F5>`**: Continue debugging
- **`<F10>`**: Step over
- **`<F11>`**: Step into
- **`<F12>`**: Step out
- **`<leader>b`**: Toggle breakpoint
- **`<leader>B`**: Set breakpoint with condition
- **`<leader>du`**: Toggle debug UI

#### Package Scripts
- **`:NpmRun`**: Show list of npm scripts to run

#### Folding (nvim-ufo)
- **`zR`**: Open all folds
- **`zM`**: Close all folds

#### LSP Features
- **`gpd`**: Preview definition (goto-preview)
- **`:LspInlayHint`**: Toggle inlay hints

---

## 13. Implementation Order

**Recommended Sequence:**

1. **Phase 0** - Treesitter parsers (must do first)
2. **Phase 1** - LSP configuration (core functionality)
3. **Phase 2** - Auto-formatting (quality of life)
4. **Phase 3** - Linting (code quality)
5. **Phase 9** - Vue-specific features (if using Vue)
6. **Phase 4** - Testing (if needed)
7. **Phase 5** - Debugging (if needed)
8. **Phase 6** - Folding (nice to have)
9. **Phase 7** - LSP features (nice to have)
10. **Phase 8** - Package scripts (nice to have)

---

## 14. Testing Checklist

After each phase, verify:
- [ ] No errors in `:checkhealth`
- [ ] No Lua errors on startup
- [ ] Relevant keybindings work as expected
- [ ] Features activate for correct filetypes
- [ ] Performance is acceptable

After full implementation:
- [ ] Create a test Vue project with TypeScript
- [ ] Write a Vue component with TypeScript
- [ ] Write tests for the component
- [ ] Set a breakpoint and debug
- [ ] Run linting and format the file
- [ ] Execute npm scripts
- [ ] Verify all web development features work together

---

## 15. Troubleshooting

### Common Issues

1. **LSP not attaching:**
   - Check `:LspInfo` to see which servers are active
   - Ensure Mason installation completed successfully
   - Verify filetype detection (`:set ft?`)

2. **Formatting not working:**
   - Check if Prettier is installed (`:MasonInstall prettier`)
   - Verify `conform.nvim` configuration
   - Check project has valid Prettier config

3. **Linting errors:**
   - Verify ESLint config file exists in project root
   - Check `nvim-lint` diagnostics (`:lua require('lint').try_lint()`)
   - Ensure eslint_d is installed for performance

4. **Debugging issues:**
   - Verify debug adapter is installed
   - Check DAP configuration matches project structure
   - Review DAP UI for error messages

---

## 16. Notes for Future Enhancements

**Potential additions based on usage:**

1. **Git integration:** Better git diff, conflict resolution
2. **HTTP client:** REST client for API testing (`rest.nvim`)
3. **Docker support:** Dockerfile syntax, container integration
4. **GraphQL support:** GraphQL syntax highlighting and autocomplete
5. **Tailwind CSS:** Tailwind class autocomplete
6. **Code coverage:** Coverage display integration
7. **Monorepo support:** Better navigation in monorepos
8. **Snippet library:** Custom snippets for your tech stack

---

## 17. Session Planning

### Session 1: Core Setup (2 hours)
- Phase 0: Treesitter parsers
- Phase 1: LSP configuration
- Phase 2: Auto-formatting
- Phase 3: Linting

### Session 2: Vue & Testing (2 hours)
- Phase 9: Vue-specific features
- Phase 4: Testing integration

### Session 3: Advanced Features (2 hours)
- Phase 5: Debugging configuration
- Phase 6: Enhanced folding
- Phase 7: LSP features
- Phase 8: Package scripts

---

## 18. Status Summary

| Phase | Status | Priority | Files Created | Lines |
|-------|--------|----------|---------------|-------|
| Phase 0 | ⏳ Not Started | CRITICAL | 1 modified | ~5 |
| Phase 1 | ⏳ Not Started | CRITICAL | 1 new | ~30 |
| Phase 2 | ⏳ Not Started | HIGH | 1 modified | ~10 |
| Phase 3 | ⏳ Not Started | HIGH | 1 modified | ~10 |
| Phase 4 | ⏳ Not Started | MEDIUM | 1 new | ~40 |
| Phase 5 | ⏳ Not Started | MEDIUM | 1 new | ~50 |
| Phase 6 | ⏳ Not Started | LOW | 1 new | ~20 |
| Phase 7 | ⏳ Not Started | MEDIUM | 1 new | ~25 |
| Phase 8 | ⏳ Not Started | LOW | 1 new | ~20 |
| Phase 9 | ⏳ Not Started | MEDIUM | 1 new | ~30 |

**Legend:** ⏳ Not Started | 🔨 In Progress | ✅ Complete | ❌ Cancelled

**Total Estimated Effort:**
- **Files to Create:** 7
- **Files to Modify:** 3
- **Total Lines of Code:** ~240
- **Estimated Time:** 6 hours (3 sessions)

---

**Last Updated:** 2026-01-01

---

## Quick Start Commands

```bash
# Start web development session
nvim

# Check Mason status
:Mason

# Check LSP status
:LspInfo

# Check health
:checkhealth

# Run tests manually
npm test

# Format file
:lua require('conform').format()

# Toggle debug UI
<leader>du
```
