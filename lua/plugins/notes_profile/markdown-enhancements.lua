-- lua/plugins/notes_profile/markdown-enhancements.lua
-- This file contains all custom functions, keymaps, and autocommands for an enhanced Markdown experience.

return {
  -- We declare a dependency on LuaSnip to ensure it's loaded before this config runs.
  "L3MON4D3/LuaSnip",
  config = function()
    local function toggle_checkbox()
      local line = vim.api.nvim_get_current_line()
      local lnum = vim.api.nvim_win_get_cursor(0)[1]

      if line:match("%[x%]") then
        local new_line = line:gsub("%[x%]", "[ ]", 1)
        vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { new_line })
      elseif line:match("%[%s%]") then
        local new_line = line:gsub("%[%s%]", "[x]", 1)
        vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { new_line })
      end
    end

    local function move_checked_to_done()
      local line = vim.api.nvim_get_current_line()
      local lnum = vim.api.nvim_win_get_cursor(0)[1]

      if not line:match("%[x%]") then
        vim.notify("Current line is not a checked checkbox.", vim.log.levels.INFO)
        return
      end

      local done_section_lnum = nil
      local buffer_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      for i, bline in ipairs(buffer_lines) do
        if bline:match("^#+%s*DONE") then
          done_section_lnum = i
          break
        end
      end

      if not done_section_lnum then
        vim.notify("No '## DONE' section found in the file.", vim.log.levels.INFO)
        return
      end

      local line_content = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
      vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, {})
      vim.api.nvim_buf_set_lines(0, done_section_lnum, done_section_lnum, false, { line_content })
      vim.notify("Moved checked item to '## DONE' section.", vim.log.levels.INFO)
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      group = vim.api.nvim_create_augroup("MarkdownEnhancements", { clear = true }),
      callback = function(args)
        require("luasnip.loaders.from_lua").load({ paths = { vim.fn.stdpath("config") .. "/lua/plugins/notes_profile/snippets" } })

        vim.keymap.set("n", "<leader>cx", toggle_checkbox, { buffer = true, desc = "Toggle Checkbox" })
        vim.keymap.set("n", "<leader>cm", move_checked_to_done, { buffer = true, desc = "Move Checked to DONE" })

        local function insert_checkbox_below()
          local lnum = vim.api.nvim_win_get_cursor(0)[1]
          local current_line = vim.api.nvim_get_current_line()
          local indent = current_line:match("^%s*") or ""
          vim.api.nvim_buf_set_lines(0, lnum, lnum, false, { indent .. "- [ ] " })
          vim.api.nvim_win_set_cursor(0, { lnum + 1, #indent + 7 })
          vim.cmd("startinsert")
        end

        vim.keymap.set("n", "<leader>ci", insert_checkbox_below, { buffer = true, desc = "Insert Checkbox Below" })
        vim.keymap.set("n", "<leader>sh", function()
          require("telescope.builtin").lsp_document_symbols({
            attach_mappings = function(prompt_bufnr, map)
              map("i", "<C-j>", require("telescope.actions").move_selection_next)
              map("i", "<C-k>", require("telescope.actions").move_selection_previous)
              return true
            end,
          })
        end, { buffer = true, desc = "Search Headings" })

        local function surround(prefix, suffix)
          if vim.fn.mode():find("[vV\x16]") then
            local keys = "c" .. prefix .. "<C-r>\"" .. suffix .. "<Esc>"
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), "n", false)
          else
            if vim.fn.expand("<cword>") ~= "" then
              local keys = "ciw" .. prefix .. "<C-r>\"" .. suffix .. "<Esc>"
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), "n", false)
            else
              local num_left = #suffix
              local keys = "i" .. prefix .. suffix .. "<Esc>" .. num_left .. "hi"
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), "n", false)
            end
          end
        end

        vim.keymap.set({ "n", "v" }, "<leader>mb", function() surround("**", "**") end, { buffer = true, desc = "Markdown Bold" })
        vim.keymap.set({ "n", "v" }, "<leader>mi", function() surround("*", "*") end, { buffer = true, desc = "Markdown Italic" })
        vim.keymap.set({ "n", "v" }, "<leader>ms", function() surround("~~", "~~") end, { buffer = true, desc = "Markdown Strikethrough" })
        vim.keymap.set({ "n", "v" }, "<leader>mc", function() surround("`", "`") end, { buffer = true, desc = "Markdown Inline Code" })

          end,
        }
