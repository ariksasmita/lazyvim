-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap

-- Map jk to Esc in insert mode (exit insert mode faster)
-- Exclude picker/telescope buffers to avoid interfering with navigation
vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopePrompt",
  callback = function()
    -- Disable jk/kj in telescope
    vim.keymap.set("i", "jk", "jk", { buffer = 0 })
    vim.keymap.set("i", "kj", "kj", { buffer = 0 })
  end,
})

keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
keymap.set("i", "kj", "<Esc>", { desc = "Exit insert mode" })

-- Scrolling through Buffers
-- USE CTRL-O CTRL-I instead
keymap.set("n", "<Tab>", ":bnext!<CR>") -- go to next buffer
keymap.set("n", "<S-Tab>", ":bprev!<CR>") -- go to prev buffer

-- Terminal actions
-- Vertical open / toggle terminal
keymap.set("n", "<leader>tv", function()
  require("snacks.terminal")(nil, { win = { position = "right" }})
end, { desc = "Terminal vertical split" })
-- Horizontal open / toggle terminal
vim.keymap.set("n", "<leader>th", function()
  require("snacks.terminal")(nil, { win = { position = "bottom" }})
end, { desc = "Terminal horizontal split" })
-- Ctrl-\ for quick horizontal terminal toggle
vim.keymap.set("n", "<C-\\>", function()
  require("snacks.terminal")(nil, { win = { position = "bottom" }})
end, { desc = "Terminal horizontal split (quick)" })
-- Terminal selector
vim.keymap.set("n", "<leader>ts", "<cmd>TermSelect<cr>", { desc = "Select terminal" })

-- Find files in a specific folder
local function get_folder_and_find_files()
  vim.ui.input({ prompt = "Folder:", completion = "dir" }, function(dir)
    if dir and dir ~= "" then
      local actions = require("telescope.actions")
      require("telescope.builtin").find_files({
        search_dirs = { dir },
        attach_mappings = function(prompt_bufnr, map)
          map("i", "<C-j>", actions.move_selection_next)
          map("i", "<C-k>", actions.move_selection_previous)
          return true
        end,
      })
    end
  end)
end

keymap.set("n", "<leader>fs", get_folder_and_find_files, { desc = "Find files in folder" })

-- Grep in a specific folder
local function get_folder_and_live_grep()
  vim.ui.input({ prompt = "Folder:", completion = "dir" }, function(dir)
    if dir and dir ~= "" then
      local actions = require("telescope.actions")
      require("telescope.builtin").live_grep({
        search_dirs = { dir },
        attach_mappings = function(prompt_bufnr, map)
          map("i", "<C-j>", actions.move_selection_next)
          map("i", "<C-k>", actions.move_selection_previous)
          return true
        end,
      })
    end
  end)
end

keymap.set("n", "<leader>fG", get_folder_and_live_grep, { desc = "Grep in folder" })
