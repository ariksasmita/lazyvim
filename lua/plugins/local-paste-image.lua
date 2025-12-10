-- lua/plugins/local-paste-image.lua
--
-- A custom, self-contained script to paste images from the clipboard into
-- markdown files. This script has no external GitHub dependencies.
--
-- REQUIRES: `pngpaste` command-line tool.
--           Install with: `brew install pngpaste`
--

local M = {}

--- Pastes an image from the clipboard into the current buffer.
-- Saves the image to a local 'assets' directory and inserts a markdown link.
function M.paste_image()
  -- 1. Check for dependencies
  if vim.fn.executable("pngpaste") == 0 then
    vim.notify("Error: `pngpaste` command not found. Please run `brew install pngpaste`.", vim.log.levels.ERROR)
    return
  end
  if vim.fn.executable("sips") == 0 then
    vim.notify("Error: `sips` command not found. This should be built into macOS.", vim.log.levels.ERROR)
    return
  end

  -- 2. Define paths
  local current_file_dir = vim.fn.expand("%:p:h")
  if current_file_dir == "" then
    vim.notify("Error: Please save the file once before pasting an image.", vim.log.levels.ERROR)
    return
  end
  local assets_dir = current_file_dir .. "/assets"
  local temp_png_path = vim.fn.tempname() .. ".png"
  local final_file_name = os.date("%Y-%m-%d-%H-%M-%S") .. ".jpg"
  local final_file_path = assets_dir .. "/" .. final_file_name

  -- 3. Create assets directory if it doesn't exist
  if vim.fn.isdirectory(assets_dir) == 0 then
    vim.fn.mkdir(assets_dir, "p")
  end

  -- 4. Paste image to a temporary file
  vim.fn.system("pngpaste " .. vim.fn.shellescape(temp_png_path))
  if vim.v.shell_error ~= 0 then
    vim.notify("Error: Failed to get image from clipboard. Is there an image copied?", vim.log.levels.ERROR)
    return
  end

  -- 5. Use `sips` to resize, convert to JPG, and save to final destination
      local sips_command = table.concat({
      "sips",
      "--setProperty format jpeg",
      "--setProperty formatOptions 75", -- Set JPEG quality to 75%
      vim.fn.shellescape(temp_png_path),
      "--out " .. vim.fn.shellescape(final_file_path),
    }, " ")  vim.fn.system(sips_command)
  vim.fn.delete(temp_png_path) -- Clean up the temporary file

  -- 6. Check result and insert markdown link
  if vim.v.shell_error == 0 then
    local relative_path = "assets/" .. final_file_name
    local markdown_link = "![](" .. relative_path .. ")"
    vim.api.nvim_put({ markdown_link }, "c", true, true)
  else
    vim.notify("Error: Failed to process image with `sips`.", vim.log.levels.ERROR)
  end
end

-- Set up the keymap
vim.keymap.set({ "n", "i" }, "<leader>p", M.paste_image, { desc = "Paste Image from Clipboard (Local)" })

-- Return an empty table to be consistent with plugin structure, even though it's not a real plugin.
return {}
