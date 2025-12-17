-- lua/plugins/notes_profile/snippets/markdown/links.lua
-- Defines custom snippets for markdown files.

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node

return {
  -- Snippet for a markdown link
  s(
    { trig = "link", name = "Markdown Link" },
    {
      t("["),
      i(1, "text"),
      t("]("),
      i(2, "url"),
      t(")"),
    }
  ),

  -- Snippet for Obsidian-style metadata front matter
  s(
    {
      trig = "meta",
      name = "Obsidian Metadata",
      dscr = "Insert YAML front matter for Obsidian notes",
    },
    {
      t({ "---", "title: " }),
      f(function()
        return vim.fn.expand("%:t:r")
      end, {}),
      t({ "", "aliases:", "  - " }),
      i(1),
      t({ "", "tags:", "  - " }),
      i(2),
      t({ "", "created: " }),
      f(function()
        return os.date("%Y-%m-%d %H:%M:%S")
      end, {}),
      t({ "", "updated: " }),
      f(function()
        return os.date("%Y-%m-%d %H:%M:%S")
      end, {}),
      t({ "", "status: " }),
      i(3, "draft"),
      t({ "", "type: " }),
      i(4, "note"),
      t({ "", "---", "" }),
      i(0),
    }
  ),
}

