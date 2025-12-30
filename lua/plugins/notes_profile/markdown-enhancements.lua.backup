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

    -- Helper function to get indent level of a line
    local function get_indent_level(line)
      local indent = line:match("^(%s*)")
      return #indent
    end

    -- Global fold expression function for markdown (YAML, headers, and lists)
    _G.markdown_fold_expr = function()
      local lnum = vim.v.lnum
      local line = vim.fn.getline(lnum)
      local next_line = vim.fn.getline(lnum + 1)
      
      -- 1. YAML frontmatter folding
      local yaml_start = vim.b.yaml_start
      local yaml_end = vim.b.yaml_end
      
      if yaml_start and yaml_end then
        if lnum == yaml_start then
          return ">1"
        elseif lnum > yaml_start and lnum < yaml_end then
          return "1"
        elseif lnum == yaml_end then
          return "<1"
        end
      end
      
      -- 2. Header-based folding
      local curr_heading = line:match("^(#+)%s+")
      local next_heading = next_line:match("^(#+)%s+")
      
      if curr_heading then
        local curr_level = #curr_heading
        if next_heading then
          local next_level = #next_heading
          if next_level <= curr_level then
            return ">" .. curr_level
          else
            return ">" .. curr_level
          end
        else
          return ">" .. curr_level
        end
      end
      
      if next_heading then
        local next_level = #next_heading
        return "s" .. next_level
      end
      
      -- 3. List item folding (including checkboxes)
      -- Match list items: -, *, +, or numbered lists, with optional checkboxes
      local curr_list = line:match("^%s*[%-%*%+]%s+") or line:match("^%s*%d+%.%s+")
      local next_list = next_line:match("^%s*[%-%*%+]%s+") or next_line:match("^%s*%d+%.%s+")
      
      if curr_list then
        local curr_indent = get_indent_level(line)
        local next_indent = get_indent_level(next_line)
        
        -- If next line has greater indent, start a fold
        if next_indent > curr_indent then
          return "a1"
        end
        
        -- If next line has less indent, end fold
        if next_list and next_indent < curr_indent then
          return "s1"
        end
      end
      
      -- For lines that are indented children of list items
      if not curr_list and line:match("^%s+%S") then
        local curr_indent = get_indent_level(line)
        local next_indent = get_indent_level(next_line)
        
        -- Continue fold if indentation is maintained or increased
        if next_indent >= curr_indent then
          return "="
        end
        
        -- End fold if next line has less indentation
        if next_indent < curr_indent then
          return "s1"
        end
      end
      
      return "="
    end

    -- Custom fold text for all markdown folds
    _G.markdown_fold_text = function()
      local foldstart = vim.v.foldstart
      local foldend = vim.v.foldend
      local line = vim.fn.getline(foldstart)
      local line_count = foldend - foldstart + 1
      
      -- 1. YAML frontmatter
      if line:match("^%-%-%-$") and foldstart == 1 then
        local lines = vim.api.nvim_buf_get_lines(0, foldstart - 1, foldend, false)
        local title = nil
        for _, l in ipairs(lines) do
          local match = l:match("^title:%s*(.+)$")
          if match then
            title = match
            break
          end
        end
        
        if title then
          return string.format("  YAML Frontmatter: %s  [%d lines]", title, line_count)
        else
          return string.format("  YAML Frontmatter  [%d lines]", line_count)
        end
      end
      
      -- 2. Headers
      local heading_match = line:match("^(#+%s+.+)$")
      if heading_match then
        return string.format("%s  [%d lines]", heading_match, line_count)
      end
      
      -- 3. List items (including checkboxes)
      local checkbox = line:match("^%s*%- %[(.)%]%s+(.+)$")
      if checkbox then
        local status = checkbox == "x" and "✓" or checkbox == " " and " " or checkbox
        local text = line:match("^%s*%- %[.%]%s+(.+)$")
        local indent = line:match("^(%s*)")
        return string.format("%s[%s] %s  [%d lines]", indent, status, text, line_count)
      end
      
      local list_item = line:match("^%s*[%-%*%+]%s+(.+)$") or line:match("^%s*%d+%.%s+(.+)$")
      if list_item then
        local indent = line:match("^(%s*)")
        return string.format("%s- %s  [%d lines]", indent, list_item, line_count)
      end
      
      -- Default: show first 50 chars
      local text = line:sub(1, 50)
      if #line > 50 then
        text = text .. "..."
      end
      return string.format("  %s  [%d lines]", text, line_count)
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

    -- Function to generate filename from YAML frontmatter
    local function generate_filename_from_yaml()
      local meta = parse_yaml_frontmatter()
      
      if vim.tbl_isempty(meta) then
        vim.notify("No YAML frontmatter found. Cannot generate filename.", vim.log.levels.WARN)
        return nil
      end
      
      if not meta.title then
        vim.notify("No 'title' field in YAML frontmatter.", vim.log.levels.WARN)
        return nil
      end
      
      if not meta.created then
        vim.notify("No 'created' field in YAML frontmatter.", vim.log.levels.WARN)
        return nil
      end
      
      -- Extract date from created field (format: YYYY-MM-DD HH:MM:SS)
      local date = meta.created:match("^(%d%d%d%d%-%d%d%-%d%d)")
      if not date then
        vim.notify("Invalid 'created' date format. Expected: YYYY-MM-DD HH:MM:SS", vim.log.levels.WARN)
        return nil
      end
      
      -- Convert title to filename-safe format (lowercase, replace spaces/special chars with hyphens)
      local title_slug = meta.title:lower()
        :gsub("%s+", "-")           -- spaces to hyphens
        :gsub("[^%w%-]", "")        -- remove non-alphanumeric except hyphens
        :gsub("%-+", "-")           -- collapse multiple hyphens
        :gsub("^%-", "")            -- remove leading hyphen
        :gsub("%-$", "")            -- remove trailing hyphen
      
      return date .. "-" .. title_slug .. ".md"
    end

    -- Function to rename current file based on YAML frontmatter
    local function rename_file_from_yaml()
      local current_file = vim.api.nvim_buf_get_name(0)
      
      if current_file == "" or not current_file:match("%.md$") then
        vim.notify("Not a markdown file.", vim.log.levels.WARN)
        return false
      end
      
      local new_filename = generate_filename_from_yaml()
      if not new_filename then
        return false
      end
      
      local dir = vim.fn.fnamemodify(current_file, ":h")
      local new_filepath = dir .. "/" .. new_filename
      
      -- Check if already has correct name
      if current_file == new_filepath then
        vim.notify("File already has correct name: " .. new_filename, vim.log.levels.INFO)
        return true
      end
      
      -- Check if target file already exists
      if vim.fn.filereadable(new_filepath) == 1 then
        vim.notify("File already exists: " .. new_filename, vim.log.levels.ERROR)
        return false
      end
      
      -- Rename the file
      local success = vim.loop.fs_rename(current_file, new_filepath)
      if success then
        -- Update buffer with new filename
        vim.cmd("file " .. vim.fn.fnameescape(new_filepath))
        vim.cmd("silent! write!")
        vim.notify("File renamed to: " .. new_filename, vim.log.levels.INFO)
        return true
      else
        vim.notify("Failed to rename file.", vim.log.levels.ERROR)
        return false
      end
    end

    -- Function to parse @remind() annotation from text
    -- Supports formats: @remind(2024-12-25), @remind(2024-12-25 14:00), @remind(tomorrow), @remind(next week)
    local function parse_remind_annotation(text)
      local remind_pattern = text:match("@remind%(([^%)]+)%)")
      if not remind_pattern then
        return nil
      end
      return remind_pattern
    end

    -- Function to convert date string to AppleScript date format
    local function date_to_applescript(date_str)
      -- Handle relative dates
      if date_str:match("^today") then
        return "(current date)"
      elseif date_str:match("^tomorrow") then
        return "((current date) + (1 * days))"
      elseif date_str:match("^next week") then
        return "((current date) + (7 * days))"
      end
      
      -- Handle absolute dates: YYYY-MM-DD or YYYY-MM-DD HH:MM
      local year, month, day, hour, min = date_str:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)%s*(%d*)%:?(%d*)$")
      if not year then
        return nil
      end
      
      hour = hour ~= "" and hour or "12"
      min = min ~= "" and min or "00"
      
      -- Convert to AppleScript date format
      local month_names = {"January", "February", "March", "April", "May", "June", 
                           "July", "August", "September", "October", "November", "December"}
      local month_name = month_names[tonumber(month)]
      
      return string.format('date "%s %s, %s at %s:%s:00"', 
        month_name, day, year, hour, min)
    end

    -- Function to get synced reminders from YAML frontmatter
    local function get_synced_reminders()
      local meta = parse_yaml_frontmatter()
      if meta.synced_reminders then
        -- Handle both inline list and multi-line list formats
        if type(meta.synced_reminders) == "table" then
          return meta.synced_reminders
        end
      end
      return {}
    end

    -- Function to update synced reminders in YAML frontmatter
    local function update_synced_reminders(synced_reminders)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local in_frontmatter = false
      local frontmatter_end = nil
      local synced_line = nil
      
      -- Find frontmatter boundaries and existing synced_reminders line
      for i, line in ipairs(lines) do
        if line == "---" then
          if not in_frontmatter then
            in_frontmatter = true
          else
            frontmatter_end = i
            break
          end
        elseif in_frontmatter and line:match("^synced_reminders:") then
          synced_line = i - 1
        end
      end
      
      if not frontmatter_end then
        vim.notify("No YAML frontmatter found.", vim.log.levels.WARN)
        return false
      end
      
      -- Format synced reminders as YAML list
      local yaml_lines = {"synced_reminders:"}
      for _, reminder in ipairs(synced_reminders) do
        table.insert(yaml_lines, string.format("  - line: %d", reminder.line))
        table.insert(yaml_lines, string.format("    date: \"%s\"", reminder.date))
        table.insert(yaml_lines, string.format("    title: \"%s\"", reminder.title))
      end
      
      -- Update or insert synced_reminders
      if synced_line then
        -- Find end of existing synced_reminders block
        local block_end = synced_line + 1
        for i = synced_line + 2, frontmatter_end - 1 do
          if lines[i]:match("^%w") then -- Next top-level key
            break
          end
          block_end = i
        end
        -- Replace existing block
        vim.api.nvim_buf_set_lines(0, synced_line, block_end, false, yaml_lines)
      else
        -- Insert before end of frontmatter
        vim.api.nvim_buf_set_lines(0, frontmatter_end - 1, frontmatter_end - 1, false, yaml_lines)
      end
      
      return true
    end

    -- Function to check if reminder already exists for a line
    local function reminder_exists(lnum, date, title)
      local synced = get_synced_reminders()
      for _, reminder in ipairs(synced) do
        if reminder.line == lnum and reminder.date == date and reminder.title == title then
          return true
        end
      end
      return false
    end

    -- Function to create Mac reminder from checkbox line
    local function create_mac_reminder_from_line(line_text, lnum)
      -- Extract checkbox and text
      local checkbox_match = line_text:match("^%s*%- %[(.?)%]%s+(.+)$")
      if not checkbox_match then
        vim.notify("Not a checkbox line.", vim.log.levels.WARN)
        return false
      end
      
      local full_text = line_text:match("^%s*%- %[.%]%s+(.+)$")
      local remind_annotation = parse_remind_annotation(full_text)
      
      if not remind_annotation then
        vim.notify("No @remind() annotation found.", vim.log.levels.WARN)
        return false
      end
      
      -- Remove @remind() annotation from title
      local title = full_text:gsub("%s*@remind%([^%)]+%)", "")
      
      -- Check if already synced
      if reminder_exists(lnum, remind_annotation, title) then
        vim.notify(string.format("Reminder already exists: %s", title), vim.log.levels.INFO)
        return false
      end
      
      -- Convert date
      local applescript_date = date_to_applescript(remind_annotation)
      if not applescript_date then
        vim.notify("Invalid date format in @remind(). Use: YYYY-MM-DD, YYYY-MM-DD HH:MM, today, tomorrow, or next week", vim.log.levels.ERROR)
        return false
      end
      
      -- Get file context for reminder body
      local filename = vim.fn.expand("%:t:r")
      local body = string.format("From: %s (line %d)", filename, lnum)
      
      -- Build AppleScript command
      local script = string.format([[
        tell application "Reminders"
          tell list "Reminders"
            make new reminder with properties {name:"%s", body:"%s", due date:%s}
          end tell
        end tell
      ]], title, body, applescript_date)
      
      -- Execute AppleScript
      local result = vim.fn.system("osascript -e " .. vim.fn.shellescape(script))
      
      if vim.v.shell_error == 0 then
        -- Add to synced reminders tracking
        local synced = get_synced_reminders()
        table.insert(synced, {
          line = lnum,
          date = remind_annotation,
          title = title,
        })
        update_synced_reminders(synced)
        
        vim.notify(string.format("Reminder created: %s", title), vim.log.levels.INFO)
        return true
      else
        vim.notify("Failed to create reminder: " .. result, vim.log.levels.ERROR)
        return false
      end
    end

    -- Function to sync all checkboxes with @remind() annotations in current file
    local function sync_reminders_to_mac()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local count = 0
      
      for i, line in ipairs(lines) do
        if line:match("^%s*%- %[.%]") and line:match("@remind%(") then
          local success = create_mac_reminder_from_line(line, i)
          if success then
            count = count + 1
          end
        end
      end
      
      if count == 0 then
        vim.notify("No checkboxes with @remind() annotations found.", vim.log.levels.INFO)
      else
        vim.notify(string.format("Created %d reminder(s) in Mac Reminders.", count), vim.log.levels.INFO)
      end
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

      -- Get the checkbox line and calculate its indentation
      local checkbox_line = buffer_lines[lnum]
      local checkbox_indent = checkbox_line:match("^(%s*)")
      local checkbox_indent_len = #checkbox_indent
      
      -- Collect the checkbox line and all its child lines (with greater indentation)
      local lines_to_move = { checkbox_line }
      local end_line = lnum
      
      -- Look for child lines (lines with greater indentation than the checkbox)
      for i = lnum + 1, #buffer_lines do
        local next_line = buffer_lines[i]
        
        -- Empty lines are considered part of the block
        if next_line:match("^%s*$") then
          table.insert(lines_to_move, next_line)
          end_line = i
        else
          -- Calculate indentation of the next line
          local next_indent = next_line:match("^(%s*)")
          local next_indent_len = #next_indent
          
          -- If next line has greater indentation, it's a child
          if next_indent_len > checkbox_indent_len then
            table.insert(lines_to_move, next_line)
            end_line = i
          else
            -- Stop when we hit a line with same or less indentation
            break
          end
        end
      end

      -- Remove the lines from their current position
      vim.api.nvim_buf_set_lines(0, lnum - 1, end_line, false, {})
      
      -- Insert the lines after the DONE section header
      -- Adjust done_section_lnum if it's after the deleted lines
      local insert_pos = done_section_lnum
      if done_section_lnum > lnum then
        insert_pos = done_section_lnum - (end_line - lnum + 1)
      end
      
      vim.api.nvim_buf_set_lines(0, insert_pos, insert_pos, false, lines_to_move)
      
      local item_count = #lines_to_move
      if item_count == 1 then
        vim.notify("Moved checked item to '## DONE' section.", vim.log.levels.INFO)
      else
        vim.notify(string.format("Moved checked item with %d child line(s) to '## DONE' section.", item_count - 1), vim.log.levels.INFO)
      end
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

    -- Auto-rename file on first save if it's a new file with YAML frontmatter
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.md",
      group = vim.api.nvim_create_augroup("MarkdownAutoRename", { clear = true }),
      callback = function()
        local current_file = vim.api.nvim_buf_get_name(0)
        local filename = vim.fn.fnamemodify(current_file, ":t")
        
        -- Only auto-rename if file doesn't already follow the date pattern
        -- Pattern: YYYY-MM-DD-*.md
        if not filename:match("^%d%d%d%d%-%d%d%-%d%d%-") then
          -- Check if buffer was recently created (within last 5 seconds)
          -- This is a heuristic to detect "new" files vs existing files
          local buf_id = vim.api.nvim_get_current_buf()
          if not vim.b[buf_id].auto_rename_done then
            vim.b[buf_id].auto_rename_done = true
            
            -- Small delay to ensure file is written
            vim.defer_fn(function()
              if vim.api.nvim_buf_is_valid(buf_id) and vim.api.nvim_buf_get_name(buf_id) == current_file then
                local success = rename_file_from_yaml()
                if success then
                  vim.notify("Auto-renamed file based on YAML frontmatter", vim.log.levels.INFO)
                end
              end
            end, 100)
          end
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
          vim.api.nvim_win_set_cursor(0, { lnum + 1, #indent + 8 })
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

        -- Keymap to manually rename file based on YAML frontmatter
        vim.keymap.set("n", "<leader>yr", function()
          rename_file_from_yaml()
        end, { buffer = true, desc = "Rename File from YAML" })

        -- Keymap to create Mac reminder from current checkbox line
        vim.keymap.set("n", "<leader>rc", function()
          local line = vim.api.nvim_get_current_line()
          local lnum = vim.api.nvim_win_get_cursor(0)[1]
          create_mac_reminder_from_line(line, lnum)
        end, { buffer = true, desc = "Create Reminder from Checkbox" })

        -- Keymap to sync all reminders in file to Mac
        vim.keymap.set("n", "<leader>rs", function()
          sync_reminders_to_mac()
        end, { buffer = true, desc = "Sync Reminders to Mac" })

        -- Keymap for full-text search in notes vault
        vim.keymap.set("n", "<leader>fn", function()
          require("telescope.builtin").live_grep({
            prompt_title = "Search in Notes",
            cwd = vim.fn.expand("~/Library/CloudStorage/OneDrive-DANAINDONESIA/notevault"),
          })
        end, { buffer = true, desc = "Full-Text Search in Notes" })

        -- Keymap to start Pomodoro timer on checkbox
        vim.keymap.set("n", "<leader>tp", function()
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
        vim.keymap.set("n", "<leader>tm", function()
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
        vim.keymap.set("n", "<leader>ts", function()
          vim.cmd("TimerStart 5m Rest")
          vim.notify("Started 5m Rest", vim.log.levels.INFO)
        end, { buffer = true, desc = "Start Short Rest Timer" })

        -- Keymap for long rest (10m)
        vim.keymap.set("n", "<leader>tl", function()
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

        -- Setup markdown folding (YAML, headers, lists)
        local buf = args.buf
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        
        -- Detect YAML frontmatter if present
        local start_line
        local end_line
        for i, line in ipairs(lines) do
          if line == "---" then
            if not start_line then
              start_line = i
            else
              end_line = i
              break
            end
          end
        end
        
        -- Store YAML boundaries if frontmatter exists at file start
        if start_line == 1 and end_line then
          vim.b[buf].yaml_start = start_line
          vim.b[buf].yaml_end = end_line
        end
        
        -- Enable folding for all markdown files
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.foldexpr = "v:lua.markdown_fold_expr()"
        vim.opt_local.foldenable = true
        vim.opt_local.foldlevel = 1  -- Start with level 1 folds open (YAML closed, headers open)
        vim.opt_local.foldtext = "v:lua.markdown_fold_text()"
        
        -- Keymap to toggle YAML frontmatter fold (if exists)
        if start_line == 1 and end_line then
          vim.keymap.set("n", "<leader>yf", function()
            local cursor = vim.api.nvim_win_get_cursor(0)
            vim.api.nvim_win_set_cursor(0, {1, 0})
            vim.cmd("normal! za")
            vim.api.nvim_win_set_cursor(0, cursor)
          end, { buffer = true, desc = "Toggle YAML Frontmatter Fold" })
        end


      end,
    })
  end,
}
