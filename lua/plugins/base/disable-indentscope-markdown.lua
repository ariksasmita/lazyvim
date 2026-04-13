-- Disable mini.indentscope for markdown files
-- This provides a cleaner, book-like reading experience
return {
  {
    "nvim-mini/mini.indentscope",
    opts = function()
      -- Exclude markdown and related filetypes from indent guides
      return {
        exclude = {
          filetypes = {
            "markdown",
            "md",
            "rmd",
            "quarto",
          },
        },
      }
    end,
  },
}
