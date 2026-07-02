return {

  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local signs = require("gitsigns")

      local function gitsigns_visual_op(op)
        return function()
          return require("gitsigns")[op]({ vim.fn.line("."), vim.fn.line("v") })
        end
      end

      signs.setup({
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 700,
          follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 700,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = "rounded",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })

          map("n", "[c", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true })

          -- Actions
          map("n", "<leader>ghs", gs.stage_hunk, { desc = "stage hunk" })
          map("n", "<leader>ghr", gs.reset_hunk, { desc = "reset hunk" })
          map("v", "<leader>hs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "stage selected hunk" })
          map("v", "<leader>hr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "reset selected hunk" })
          map("n", "<leader>ghS", gs.stage_buffer, { desc = "stage buffer" })
          map("n", "<leader>ghu", gs.undo_stage_hunk, { desc = "undo stage" })
          map("n", "<leader>ghR", gs.reset_buffer, { desc = "reset buffer" })
          map("n", "<leader>ghp", gs.preview_hunk, { desc = "preview hunk" })
          map("n", "<leader>gm", function()
            gs.blame_line({ full = true })
          end, { desc = "blame line (full)" })
          map("n", "<leader>ghd", gs.diffthis, { desc = "diff hunk" })
          map("n", "<leader>ght", gs.toggle_deleted, { desc = "toggle deleted" })

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      })
    end,
    keys = {
      { "<leader>ghd" },
      { "<leader>ghp" },
      { "<leader>ghR" },
      { "<leader>ghr" },
      { "<leader>ghs" },
      { "<leader>ghS" },
      { "<leader>ght" },
      { "<leader>ghu" },
      { "<leader>gm" },
    },
  },
}
