-- Minimal test for search crash
-- Run with: nvim --clean -u test_search_minimal.lua

-- Install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Minimal setup
require("lazy").setup({
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
      vim.keymap.set("n", "<Space>sg", function()
        require("telescope.builtin").live_grep()
      end, { desc = "Search" })
    end,
  },
})

print("Minimal test config loaded. Press <Space>sg to test search.")
