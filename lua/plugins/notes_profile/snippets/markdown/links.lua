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
}

