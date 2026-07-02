return {
  "pablopunk/pi.nvim",
  lazy = false,
  opts = {
    binary = "pi",
    provider = "9router",
    model = "cx/gpt-5.3-codex",
    thinking = "off",
    system_prompt = nil, -- Use pi's default coding assistant with full tool access
    append_system_prompt = nil, -- Don't override pi's established behavior
    context = {
      max_bytes = 48000, -- Larger context for better codebase awareness
      ask = {
        surrounding_lines = 100, -- More surrounding context
      },
      selection = {
        surrounding_lines = 50,
      },
      diagnostics = {
        enabled = true,
      },
    },
    skills = true, -- Keep skills for domain expertise
    extensions = true, -- Keep extensions for additional capabilities
  },
  config = function(_, opts)
    require("pi").setup(opts)

    -- Floating terminal for full pi CLI experience
    local function create_floating_pi(cmd)
      local width = math.floor(vim.o.columns * 0.9)
      local height = math.floor(vim.o.lines * 0.85)
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)

      local buf = vim.api.nvim_create_buf(false, true)
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
      })

      vim.fn.termopen(cmd, {
        on_exit = function(_, exit_code, _)
          vim.schedule(function()
            if exit_code == 0 then
              vim.notify("✓ Pi completed", vim.log.levels.INFO)
            end
          end)
        end,
      })

      -- Terminal keymaps (set after terminal is ready)
      vim.api.nvim_create_autocmd("TermOpen", {
        buffer = buf,
        callback = function()
          -- Exit terminal mode to normal mode
          vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", { buffer = buf, silent = true })
          -- Close window in normal mode
          vim.keymap.set("n", "q", function()
            vim.api.nvim_win_close(win, true)
          end, { buffer = buf, silent = true })
          -- Close window in terminal mode (with exit terminal first)
          vim.keymap.set("t", "q", function()
            vim.cmd("stopinsert")
            vim.api.nvim_win_close(win, true)
          end, { buffer = buf, silent = true })
          -- Alternative close with Ctrl+q
          vim.keymap.set("t", "<C-q>", function()
            vim.cmd("stopinsert")
            vim.api.nvim_win_close(win, true)
          end, { buffer = buf, silent = true })
        end,
        once = true,
      })

      vim.cmd("startinsert")
      return buf, win
    end

    -- Pi with current buffer as file context
    local function pi_buffer(prompt, use_range)
      local lines
      if use_range then
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
      else
        lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      end

      local temp_file = vim.fn.tempname() .. "." .. (vim.bo.filetype or "txt")
      vim.fn.writefile(lines, temp_file)

      local buf, win = create_floating_pi(string.format("pi '%s' %s", prompt, temp_file))

      -- Cleanup temp file when window closes
      vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(win),
        callback = function()
          vim.fn.delete(temp_file)
        end,
        once = true,
      })
    end

    -- Pi with full project context (uses AGENTS.md, skills, extensions automatically)
    local function pi_project()
      local prompt = vim.fn.input("Pi (project context): ")
      if prompt == "" then return end
      create_floating_pi(string.format("pi '%s'", prompt))
    end

    -- Create commands
    vim.api.nvim_create_user_command("PiFloat", function(opts)
      local prompt = vim.fn.input("Pi: ")
      if prompt == "" then return end
      pi_buffer(prompt, opts.range > 0)
    end, { range = true, nargs = 0, desc = "Pi in floating terminal with buffer context" })

    vim.api.nvim_create_user_command("PiProject", pi_project, {
      nargs = 0,
      desc = "Pi with full project context (skills, AGENTS.md, tools)",
    })

    -- Keybindings for enhanced pi experience
    vim.keymap.set("n", "<leader>aif", ":PiFloat<CR>", { desc = "Pi float (buffer)" })
    vim.keymap.set("v", "<leader>aif", ":PiFloat<CR>", { desc = "Pi float (selection)" })
    vim.keymap.set("n", "<leader>aip", ":PiProject<CR>", { desc = "Pi project context" })
  end,
  keys = {
    -- Standard pi.nvim keybindings
    {
      "<leader>ai",
      ":PiAsk<CR>",
      mode = "n",
      desc = "Pi quick ask (buffer)",
    },
    {
      "<leader>ai",
      ":<C-u>PiAskSelection<CR>",
      mode = "v",
      desc = "Pi quick ask (selection)",
    },
    {
      "<leader>aic",
      ":PiCancel<CR>",
      mode = "n",
      desc = "Cancel pi request",
    },
    {
      "<leader>ail",
      ":PiLog<CR>",
      mode = "n",
      desc = "Open pi session log",
    },
  },
}