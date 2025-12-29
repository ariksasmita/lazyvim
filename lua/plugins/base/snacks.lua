return {
  -- Modify tha snacks.nvim plugin
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = false, -- Disable snacks image rendering, use image.nvim instead
      },
      -- Configuration for the explorer
      picker = {
        sources = {
          explorer = {
            actions = {
              copy_relative_path_cwd = {
                action = function(_, item)
                  if not item then return end

                  -- --- Debugging: Check the values ---
                  print("item.file:", item.file)
                  print("Current Working Directory:", vim.fn.getcwd())
                  -- -----------------------------------

                  local relative_path = vim.fn.fnamemodify(item.file, ":.")

                  -- --- Debugging: Check the result of fnamemodify ---
                  print("Result of fnamemodify(:.):", relative_path)
                  -- -------------------------------------------------

                  vim.fn.setreg("+", relative_path, "c")
                  vim.notify("Copied relative path to clipboard: " .. relative_path)
                end,
                desc = "Copy relative path to clipboard",
              },
              copy_relative_path_to_root = { -- Changed action name for clarity
                action = function(_, item)
                  if not item then return end

                  local full_path = item.file
                  -- Get the LazyVim detected root directory
                  local root = require("lazy.core.config").options.root

                  -- Calculate the path relative to the root
                  -- We'll manually construct this as fnamemodify(:.) is relative to cwd
                  -- A common way is to remove the root prefix from the full path
                  local relative_path = string.gsub(full_path, "^" .. root .. "/", "", 1)

                  -- --- Debugging: Check the values ---
                  print("item.file:", full_path)
                  print("LazyVim Root Directory:", root)
                  print("Calculated Relative Path:", relative_path)
                  -- -----------------------------------


                  vim.fn.setreg("+", relative_path, "c")
                  vim.notify("Copied relative path: " .. relative_path, vim.log.levels.INFO)
                end,
                desc = "Copy Relative Path (Root)", -- Changed description
              },
              copy_relative_path_to_project_root = {
                action = function(_, item)
                  if not item then return end

                  local full_path = item.file
                  local file_dir = vim.fn.fnamemodify(full_path, ":h") -- Get the directory of the file

                  -- Find the project root by searching upwards for a marker (e.g., .git)
                  -- finddir returns the directory *containing* the marker.
                  local project_root = vim.fn.finddir(".git", file_dir .. ";")

                  -- If no .git was found, you might want to fallback or handle this case.
                  if project_root == "" then
                     vim.notify("Project root marker (.git) not found. Copying full path instead.", vim.log.levels.WARN)
                     vim.fn.setreg("+", full_path, "c") -- Copy full path as a fallback
                     return
                  end

                  -- Ensure project_root has a trailing slash for consistent path manipulation
                   if not project_root:match("/$") then
                     project_root = project_root .. "/"
                   end

                  -- Calculate the path relative to the project root
                  -- Remove the project_root prefix from the full path
                  local relative_path = string.gsub(full_path, "^" .. project_root, "", 1)

                  -- --- Debugging: Check the values ---
                  -- print("item.file:", full_path)
                  -- print("File Directory:", file_dir)
                  -- print("Found Project Root:", project_root) -- This should now be the directory containing .git
                  -- print("Calculated Relative Path:", relative_path)
                  -- -----------------------------------

                  vim.fn.setreg("+", relative_path, "c")
                  vim.notify("Copied relative path: " .. relative_path, vim.log.levels.INFO)
                end,
                desc = "Copy Relative Path (Project Root)",
              },
            },
            win = {
              list = {
                keys = {
                  ["<C-y>"] = "copy_relative_path_to_project_root", -- Changed key mapping for clarity
                  ["<C-r>"] = "copy_relative_path_cwd", -- Changed key mapping for clarity
                  -- Map your custom action to a key
                  -- ["y"] = {
                  --   name = "Yank (Copy)",
                  --   ["r"] = "copy_relative_path_cwd"
                  -- },
                }
              }
            }
          }
        }
      }
    }
  }
}
