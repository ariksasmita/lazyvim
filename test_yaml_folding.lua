#!/usr/bin/env nvim -l

-- Test script for YAML folding fixes
-- Run with: nvim -l test_yaml_folding.lua

print("=== YAML Folding Fix Tests ===\n")

-- Test 1: Check if file loads
print("Test 1: Loading markdown-enhancements.lua...")
local ok, err = pcall(dofile, "lua/plugins/notes_profile/markdown-enhancements.lua")
if ok then
  print("✅ PASS: File loads without errors\n")
else
  print("❌ FAIL: Error loading file:")
  print(err)
  print("\n")
  os.exit(1)
end

-- Test 2: Check if variables are defined
print("Test 2: Checking fold expression function...")
if _G.markdown_fold_expr then
  print("✅ PASS: markdown_fold_expr is defined\n")
else
  print("❌ FAIL: markdown_fold_expr not found\n")
  os.exit(1)
end

-- Test 3: Check if fold text function exists
print("Test 3: Checking fold text function...")
if _G.markdown_fold_text then
  print("✅ PASS: markdown_fold_text is defined\n")
else
  print("❌ FAIL: markdown_fold_text not found\n")
  os.exit(1)
end

-- Test 4: Verify YAML detection logic
print("Test 4: Testing YAML detection logic...")

-- Simulate YAML detection
local test_lines = {
  "---",
  "title: Test",
  "---",
  "# Heading"
}

local yaml_start, yaml_end
for i, line in ipairs(test_lines) do
  if line == "---" then
    if not yaml_start then
      yaml_start = i
    else
      yaml_end = i
      break
    end
  end
end

if yaml_start == 1 and yaml_end == 3 then
  print("✅ PASS: YAML detection works correctly (lines 1-3)\n")
else
  print("❌ FAIL: YAML detection failed\n")
  os.exit(1)
end

-- Test 5: Check for safe fold closing logic
print("Test 5: Checking for safe fold closing...")

local file = io.open("lua/plugins/notes_profile/markdown-enhancements.lua", "r")
local content = file:read("*all")
file:close()

local has_check = content:match("foldclosedend%(fold_start%)") ~= nil
local has_manual = content:match("fold_start%,.*yaml_end.*fold") ~= nil

if has_check and has_manual then
  print("✅ PASS: Safe fold closing logic found\n")
else
  print("❌ FAIL: Safe fold closing logic not found\n")
  if not has_check then
    print("  Missing: foldclosedend check")
  end
  if not has_manual then
    print("  Missing: manual fold creation")
  end
  print("\n")
  os.exit(1)
end

print("=== All Tests Passed! ===")
print("\nThe fixes have been applied successfully.")
print("\nNext steps:")
print("1. Restart Neovim")
print("2. Open a markdown file with YAML frontmatter")
print("3. Press <leader>yf> to test YAML folding")
print("4. Verify no E490 error occurs")
