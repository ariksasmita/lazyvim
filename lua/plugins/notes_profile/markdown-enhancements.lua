-- lua/plugins/notes_profile/markdown-enhancements.lua
-- This file contains all custom functions, keymaps, and autocommands for an enhanced Markdown experience.

return {
  -- We declare a dependency on LuaSnip to ensure it's loaded before this config runs.
  "L3MON4D3/LuaSnip",
  config = function()
    if package.loaded["blink.cmp"] then
      require("blink.cmp.sources").luasnip.add_loader(function()
        require("luasnip.loaders.from_lua").load({
          paths = {
            vim.fn.stdpath("config") .. "/lua/plugins/notes_profile/snippets",
          },
        })
      end)
    end

    -- Function to parse YAML frontmatter from current buffer
    local function parse_yaml_frontmatter()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local frontmatter = {}
      local in_frontmatter = false
      for i, line in ipairs(lines) do
        if line == "---" then
          if not in_frontmatter then
            in_frontmatter = true
          else
            break
          end
        elseif in_frontmatter then
          local key, value = line:match("^(%w+):%s*(.+)$")
          if key and value then
            frontmatter[key] = value
          end
        end
      end
      return frontmatter
    end

    -- Function to parse YAML frontmatter from a file (enhanced to handle lists)
    local function parse_yaml_from_file(filepath)
      local file = io.open(filepath, "r")
      if not file then return {} end
      local lines = {}
      for line in file:lines() do
        table.insert(lines, line)
      end
      file:close()

      local frontmatter = {}
      local in_frontmatter = false
      local current_key = nil
      local current_list = nil
      for _, line in ipairs(lines) do
        if line == "---" then
          if not in_frontmatter then
            in_frontmatter = true
          else
            break
          end
        elseif in_frontmatter then
          local key, value = line:match("^(%w+):%s*(.*)$")
          if key then
            value = value:match("^%s*(.-)%s*$") or value -- trim whitespace
            if current_list then
              frontmatter[current_key] = current_list
              current_list = nil
            end
            current_key = key
            if value == "" then
              current_list = {}
            elseif value:match("^%[") then
              -- inline list, split by comma
              local list = {}
              for item in value:gmatch("[^,%[%]]+") do
                table.insert(list, item:match("^%s*(.-)%s*$"))
              end
              frontmatter[key] = list
              current_key = nil
            else
              frontmatter[key] = value
              current_key = nil
            end
          elseif current_key and line:match("^%s*- (.+)") then
            if not current_list then current_list = {} end
            table.insert(current_list, line:match("^%s*- (.+)"))
          elseif line == "" and current_list then
            frontmatter[current_key] = current_list
            current_list = nil
            current_key = nil
          end
        end
      end
      if current_list then
        frontmatter[current_key] = current_list
      end
      return frontmatter
    end

    local notes_cache = nil
    local cache_time = 0

    -- Function to collect all note metadata with caching
    local function collect_notes_metadata()
      local notes_dir = vim.fn.expand("~/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault")
      local current_time = vim.fn.localtime()
      if notes_cache and (current_time - cache_time) < 60 then -- cache for 60 seconds
        return notes_cache
      end
      local cmd = "find " .. vim.fn.shellescape(notes_dir) .. " -name '*.md' -type f"
      local md_files = vim.fn.systemlist(cmd)
      local notes = {}
      for _, filepath in ipairs(md_files) do
        local meta = parse_yaml_from_file(filepath)
        if not vim.tbl_isempty(meta) then
          local relative_path = vim.fn.fnamemodify(filepath, ":~:.")
          table.insert(notes, {
            filepath = filepath,
            relative_path = relative_path,
            title = meta.title or vim.fn.fnamemodify(filepath, ":t:r"),
            metadata = meta,
          })
        end
      end
      -- Sort by updated date descending, then by title
      table.sort(notes, function(a, b)
        local a_date = a.metadata.updated or ""
        local b_date = b.metadata.updated or ""
        if a_date ~= b_date then
          return a_date > b_date
        end
        return (a.title or "") < (b.title or "")
      end)
      return notes
    end

    -- Custom Telescope picker for metadata search
    local function metadata_search_picker()
      local notes = collect_notes_metadata()
      local picker_entries = {}
      for _, note in ipairs(notes) do
        local status = note.metadata.status or "N/A"
        local tags_str = type(note.metadata.tags) == "table" and table.concat(note.metadata.tags, ",") or note.metadata.tags or "N/A"
        local display = note.title .. " [status:" .. status .. "] [tags:" .. tags_str .. "]"
        local ordinal = note.title .. " status:" .. status .. " tags:" .. tags_str
        table.insert(picker_entries, {
          value = note.relative_path,
          display = display,
          ordinal = ordinal,
          note = note,
        })
      end

      require("telescope.pickers").new({}, {
        prompt_title = "Search Notes by Metadata",
        finder = require("telescope.finders").new_table({
          results = picker_entries,
          entry_maker = function(entry)
            return {
              value = entry.value,
              display = entry.display,
              ordinal = entry.ordinal,
              note = entry.note,
            }
          end,
        }),
        sorter = require("telescope.sorters").get_generic_fuzzy_sorter(),
        attach_mappings = function(prompt_bufnr, map)
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              vim.cmd("edit " .. selection.note.filepath)
            end
          end)
          map("i", "<C-j>", actions.move_selection_next)
          map("i", "<C-k>", actions.move_selection_previous)
          return true
        end,
        previewer = require("telescope.previewers").new_buffer_previewer({
          define_preview = function(self, entry)
            local filepath = entry.note.filepath
            local bufnr = self.state.bufnr
            local lines = vim.fn.readfile(filepath, "", 20) -- Preview first 20 lines
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
            if #lines == 20 then
              vim.api.nvim_buf_set_lines(bufnr, 20, 20, false, {"... (truncated)"})
            end
            vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
          end,
        }),
      }):find()
    end

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

    -- Auto-update 'updated' field in YAML on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.md",
      group = vim.api.nvim_create_augroup("MarkdownAutoUpdate", { clear = true }),
      callback = function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local in_frontmatter = false
        local updated_line = nil
        for i, line in ipairs(lines) do
          if line == "---" then
            if not in_frontmatter then
              in_frontmatter = true
            else
              break
            end
          elseif in_frontmatter and line:match("^updated:") then
            updated_line = i - 1
            break
          end
        end
        if updated_line then
          local now = os.date("%Y-%m-%d %H:%M:%S")
          vim.api.nvim_buf_set_lines(0, updated_line, updated_line + 1, false, { "updated: " .. now })
        end
      end,
    })

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
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local headings = {}
          for i, line in ipairs(lines) do
            local level, title = line:match("^(#+)%s+(.+)$")
            if level and title then
              table.insert(headings, {
                lnum = i,
                level = #level,
                title = title,
                display = string.rep("#", #level) .. " " .. title,
              })
            end
          end
          require("telescope.pickers").new({
            layout_config = {
              width = 0.6,
              height = 0.4,
            },
          }, {
            prompt_title = "Search Headings",
            finder = require("telescope.finders").new_table({
              results = headings,
              entry_maker = function(entry)
                return {
                  value = entry.lnum,
                  display = entry.display,
                  ordinal = entry.display,
                  lnum = entry.lnum,
                }
              end,
            }),
            sorter = require("telescope.sorters").get_generic_fuzzy_sorter(),
            attach_mappings = function(prompt_bufnr, map)
              local actions = require("telescope.actions")
              local action_state = require("telescope.actions.state")
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                  vim.api.nvim_win_set_cursor(0, {selection.lnum, 0})
                end
              end)
              map("i", "<C-j>", actions.move_selection_next)
              map("i", "<C-k>", actions.move_selection_previous)
              return true
            end,
          }):find()
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

        -- Keymap for Code Block
        vim.keymap.set({ "n", "v" }, "<leader>mC", function()
          local mode = vim.fn.mode()
          if mode:find("[vV\x16]") then -- Visual modes
            vim.cmd("normal! c```<CR><C-r>\"<CR>```")
          else -- Normal mode
            vim.cmd("normal! o```<CR><CR>```<Esc>O")
          end
        end, { buffer = true, desc = "Markdown Code Block" })

        -- Keymap to display YAML metadata
        vim.keymap.set("n", "<leader>ym", function()
          local meta = parse_yaml_frontmatter()
          if vim.tbl_isempty(meta) then
            vim.notify("No YAML frontmatter found.", vim.log.levels.INFO)
            return
          end
          local msg = "Metadata:\n"
          for k, v in pairs(meta) do
            msg = msg .. k .. ": " .. v .. "\n"
          end
          vim.notify(msg, vim.log.levels.INFO)
        end, { buffer = true, desc = "Show YAML Metadata" })

        -- Keymap to insert YAML frontmatter manually
        vim.keymap.set("n", "<leader>yh", function()
          local title = vim.fn.expand("%:t:r")
          local now = os.date("%Y-%m-%d %H:%M:%S")
          local frontmatter = {
            "---",
            "title: " .. title,
            "aliases:",
            "  - ",
            "tags:",
            "  - ",
            "created: " .. now,
            "updated: " .. now,
            "status: draft",
            "type: note",
            "---",
            "",
          }
          vim.api.nvim_buf_set_lines(0, 0, 0, false, frontmatter)
          vim.api.nvim_win_set_cursor(0, {2, #frontmatter[2]})
        end, { buffer = true, desc = "Insert YAML Frontmatter" })

        -- Keymap to insert meeting note template
        vim.keymap.set("n", "<leader>yhm", function()
          local title = vim.fn.expand("%:t:r")
          local now = os.date("%Y-%m-%d %H:%M:%S")
          local frontmatter = {
            "---",
            "title: " .. title,
            "aliases:",
            "  - ",
            "tags:",
            "  - meeting",
            "created: " .. now,
            "updated: " .. now,
            "status: draft",
            "type: meeting",
            "attendees:",
            "  - ",
            "date: " .. os.date("%Y-%m-%d"),
            "---",
            "",
            "# Meeting Notes: " .. title,
            "",
            "## Attendees",
            "- ",
            "",
            "## Agenda",
            "- ",
            "",
            "## Discussion",
            "",
            "## Action Items",
            "- [ ] ",
            "",
          }
          vim.api.nvim_buf_set_lines(0, 0, 0, false, frontmatter)
          vim.api.nvim_win_set_cursor(0, {2, #frontmatter[2]})
        end, { buffer = true, desc = "Insert Meeting Note Template" })

        -- Keymap to insert backlink via Telescope
        vim.keymap.set("n", "<leader>bl", function()
          require("telescope.builtin").find_files({
            prompt_title = "Select Note for Backlink",
            cwd = vim.fn.expand("~/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault"),
            find_command = { "find", ".", "-name", "*.md", "-type", "f" },
            attach_mappings = function(prompt_bufnr, map)
              local actions = require("telescope.actions")
              local action_state = require("telescope.actions.state")
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                  local telescope_cwd = vim.fn.expand("~/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault")
                  local selected_abs = telescope_cwd .. "/" .. selection.value
                  local filepath = vim.fn.fnamemodify(selected_abs, ":~:.")
                  local title = vim.fn.fnamemodify(selected_abs, ":t:r")
                  local link = "[" .. title .. "](" .. filepath .. ")"
                  vim.api.nvim_put({ link }, "c", true, true)
                end
              end)
              map("i", "<C-j>", actions.move_selection_next)
              map("i", "<C-k>", actions.move_selection_previous)
              return true
            end,
          })
        end, { buffer = true, desc = "Insert Backlink" })

        -- Keymap for metadata search
        vim.keymap.set("n", "<leader>ys", metadata_search_picker, { buffer = true, desc = "YAML Search" })

        -- Keymap for full-text search in notes vault
        vim.keymap.set("n", "<leader>fn", function()
          require("telescope.builtin").live_grep({
            prompt_title = "Search in Notes",
            cwd = vim.fn.expand("~/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault"),
          })
        end, { buffer = true, desc = "Full-Text Search in Notes" })

        -- Keymap to start Pomodoro timer on checkbox
        vim.keymap.set("n", "<leader>pt", function()
          local line = vim.api.nvim_get_current_line()
          if line:match("^%s*- %[.%] ") then
            local text = line:match("^%s*- %[.%] (.*)")
            if text then
              local short = text:gsub("%W", "_"):sub(1,10)
              vim.cmd("TimerStart 25m " .. short)
              vim.notify("Started 25m Pomodoro: " .. short, vim.log.levels.INFO)
            end
          else
            vim.notify("Not on a checkbox line", vim.log.levels.WARN)
          end
        end, { buffer = true, desc = "Start Pomodoro on Checkbox" })

        -- Keymap to mark Pomodoro session on checkbox
        vim.keymap.set("n", "<leader>pm", function()
          local line = vim.api.nvim_get_current_line()
          local lnum = vim.api.nvim_win_get_cursor(0)[1]
          if line:match("^%s*- %[.%] ") then
            local current_count = 0
            local count_match = line:match(" | %[([*]*)%]")
            if count_match then
              current_count = #count_match
            end
            local new_count = current_count + 1
            local new_marker = " | [" .. string.rep("*", new_count) .. "]"
            if count_match then
              line = line:gsub(" | %[([*]*)%]", new_marker)
            else
              line = line .. new_marker
            end
            vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, {line})
            vim.notify("Marked session: " .. new_count .. " total", vim.log.levels.INFO)
          else
            vim.notify("Not on a checkbox line", vim.log.levels.WARN)
          end
        end, { buffer = true, desc = "Mark Pomodoro Session on Checkbox" })

        -- Keymap for short rest (5m)
        vim.keymap.set("n", "<leader>prs", function()
          vim.cmd("TimerStart 5m Rest")
          vim.notify("Started 5m Rest", vim.log.levels.INFO)
        end, { buffer = true, desc = "Start Short Rest Timer" })

        -- Keymap for long rest (10m)
        vim.keymap.set("n", "<leader>prl", function()
          vim.cmd("TimerStart 10m Rest")
          vim.notify("Started 10m Rest", vim.log.levels.INFO)
        end, { buffer = true, desc = "Start Long Rest Timer" })

        -- Keymap to generate Table of Contents
        vim.keymap.set("n", "<leader>toc", function()
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local toc = { "## Table of Contents", "" }
          for i, line in ipairs(lines) do
            local level, title = line:match("^(#+)%s+(.+)$")
            if level and title then
              local indent = string.rep("  ", #level - 1)
              local link = "[" .. title .. "](#" .. title:lower():gsub("%s+", "-"):gsub("[^%w%-]", "") .. ")"
              table.insert(toc, indent .. "- " .. link)
            end
          end
          table.insert(toc, "")
          -- Insert at top, after frontmatter if any
          local insert_line = 0
          for i, line in ipairs(lines) do
            if line == "---" then
              if i > 1 then
                insert_line = i + 1
                break
              end
            elseif line:match("^#") then
              insert_line = i - 1
              break
            end
          end
          vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, toc)
          vim.notify("TOC generated", vim.log.levels.INFO)
        end, { buffer = true, desc = "Generate Table of Contents" })



        -- Keymap to show word/character count
        vim.keymap.set("n", "<leader>wc", function()
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local words = 0
          local chars = 0
          for _, line in ipairs(lines) do
            chars = chars + #line
            for word in line:gmatch("%S+") do
              words = words + 1
            end
          end
          vim.notify(string.format("Words: %d, Characters: %d", words, chars), vim.log.levels.INFO)
        end, { buffer = true, desc = "Word/Character Count" })



        -- Auto-continue Markdown lists
        local function get_list_prefix(line)
          local marker = line:match("^%s*([-*+]%s+)")
          if marker then
            return marker
          end
          local num = line:match("^%s*(%d+)%.%s+")
          if num then
            local next_num = tostring(tonumber(num) + 1)
            return next_num .. ". "
          end
          return nil
        end

        vim.keymap.set("i", "<CR>", function()
          local line = vim.api.nvim_get_current_line()
          local prefix = get_list_prefix(line)
          if prefix then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>" .. prefix, true, true, true), "n", false)
          else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, true, true), "n", false)
          end
        end, { buffer = true })

        vim.keymap.set("n", "o", function()
          local line = vim.api.nvim_get_current_line()
          local prefix = get_list_prefix(line)
          if prefix then
            vim.api.nvim_feedkeys("o" .. prefix, "n", false)
          else
            vim.api.nvim_feedkeys("o", "n", false)
          end
        end, { buffer = true })

        vim.keymap.set("n", "O", function()
          local line = vim.api.nvim_get_current_line()
          local prefix = get_list_prefix(line)
          if prefix then
            vim.api.nvim_feedkeys("O" .. prefix, "n", false)
          else
            vim.api.nvim_feedkeys("O", "n", false)
          end
        end, { buffer = true })
      end,
    })
  end,
}
