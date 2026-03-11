-- Test script for markview.nvim and foldtext configuration
-- Run with: nvim --headless -c "luafile /path/to/test_markview.lua" +qa

local result = {
    tests = {},
    errors = {},
}

local function test(name, fn)
    local success, err = pcall(fn)
    if success then
        table.insert(result.tests, { name = name, status = "PASS" })
        print("✅ PASS: " .. name)
    else
        table.insert(result.tests, { name = name, status = "FAIL", error = err })
        table.insert(result.errors, { name = name, error = err })
        print("❌ FAIL: " .. name)
        print("   Error: " .. tostring(err))
    end
end

-- Test 1: Load foldtext module
test("Load markdown-foldtext module", function()
    local foldtext = require('notes_profile_modules.markdown-foldtext')
    assert(type(foldtext) == "table", "Module should return a table")
    assert(type(foldtext.markdown_foldtext) == "function", "Should have markdown_foldtext function")
end)

-- Test 2: Check foldtext function returns expected output
test("markdown_foldtext function exists", function()
    local foldtext = require('notes_profile_modules.markdown-foldtext')
    local func = foldtext.markdown_foldtext
    assert(type(func) == "function", "Function should be callable")
end)

-- Test 3: Check heading icons are defined
test("Heading icons are defined", function()
    local foldtext = require('notes_profile_modules.markdown-foldtext')
    local icons = foldtext.heading_icons
    assert(type(icons) == "table", "Icons should be a table")
    assert(#icons == 6, "Should have 6 heading icons")
    assert(icons[1] == "󰉋 ", "H1 icon should be 󰉋")
    assert(icons[2] == "󰉌 ", "H2 icon should be 󰉌")
    assert(icons[3] == "󰉏 ", "H3 icon should be 󰉏")
end)

-- Test 4: Check markview plugin spec exists
test("markview plugin spec exists", function()
    local markview_spec = loadfile('/Users/sasmitai/.config/nvim/lua/plugins/base/markview.lua')
    assert(markview_spec, "markview.lua should be loadable")
    local spec = markview_spec()
    assert(type(spec) == "table", "Plugin spec should be a table")
    assert(spec[1] == "OXY2DEV/markview.nvim", "Should be markview plugin")
end)

-- Test 5: Check markdown-enhancements has correct foldtext path
test("markdown-enhancements foldtext path is correct", function()
    local enhancements = loadfile('/Users/sasmitai/.config/nvim/lua/plugins/notes_profile/markdown-enhancements.lua')
    assert(enhancements, "markdown-enhancements.lua should be loadable")
    local content = io.open('/Users/sasmitai/.config/nvim/lua/plugins/notes_profile/markdown-enhancements.lua'):read('*a')
    assert(content:find("notes_profile_modules%.markdown%-foldtext"), "Should reference new foldtext module")
    assert(content:find("v:lua%.require%('notes_profile_modules%.markdown%-foldtext'%)%.markdown_foldtext%(%),"),
        "Should use correct require path")
end)

-- Test 6: Verify old foldtext path is removed
test("Old foldtext path is removed", function()
    local content = io.open('/Users/sasmitai/.config/nvim/lua/plugins/notes_profile/markdown-enhancements.lua'):read('*a')
    local has_old_path = content:find("v:lua%.markdown_fold_text%(%)")
    assert(not has_old_path, "Should NOT have old foldtext path")
end)

-- Test 7: Check markview checkbox config
test("markview checkbox config uses correct syntax", function()
    local content = io.open('/Users/sasmitai/.config/nvim/lua/plugins/base/markview.lua'):read('*a')
    assert(content:find('%["_%"%]'), "Should have [_] cancelled checkbox config")
    assert(content:find('%["-%"%"%]'), "Should have [-] in-progress checkbox config")
    assert(content:find('text = '), "Should use 'text' not 'icon'")
    assert(content:find('scope_hl = '), "Should use 'scope_hl' property")
end)

-- Print summary
print("\n" .. string.rep("=", 60))
print("TEST SUMMARY")
print(string.rep("=", 60))
print(string.format("Total Tests: %d", #result.tests))
local passed = 0
for _, test in ipairs(result.tests) do
    if test.status == "PASS" then
        passed = passed + 1
    end
end
print(string.format("Passed: %d", passed))
print(string.format("Failed: %d", #result.errors))

if #result.errors > 0 then
    print("\nERRORS:")
    for _, err in ipairs(result.errors) do
        print(string.format("  - %s: %s", err.name, err.error))
    end
end

print(string.rep("=", 60))

-- Exit with appropriate code
vim.cmd(#result.errors > 0 and "cquit" or "quit")
