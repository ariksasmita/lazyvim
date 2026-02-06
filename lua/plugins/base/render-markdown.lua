  return {
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = false,  -- DISABLED: Switched to markview.nvim for full 4-state checkbox support
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      checkbox = {
        enabled = true,
        position = 'overlay',
        unchecked = {
          icon = '󰄱',
        },
        in_progress = {              -- NEW
          icon = '󰔛',          -- clock icon
        },
        checked = {
          icon = '󰄵',
        },
        cancelled = {                -- NEW
          icon = '󰅰',          -- close/cancel icon
        },
      },
      -- Disable image rendering in render-markdown, let image.nvim handle it
      render_modes = { 'n', 'c' },
      anti_conceal = {
        enabled = true,
      },
    },
}
