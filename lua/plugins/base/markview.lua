-- markview.nvim configuration
-- Supports 4-state checkbox system: [ ] (pending), [-] (in_progress), [x] (checked), [_] (cancelled)

return {
  'OXY2DEV/markview.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  -- IMPORTANT: Don't lazy load - must load after colorscheme
  lazy = false,
  ---@module 'markview'
  ---@type mkv.config
  opts = function()
    -- Note: We can optionally load config here, but using static icons is more reliable
    -- local config = require('notes_profile_modules.config')

    return {
      -- Preview configuration
      preview = {
        enable = true,
        filetypes = { 'markdown', 'md', 'rmd', 'quarto' },
        modes = { 'n', 'c' },  -- Normal and command mode only (NOT insert mode)
        hybrid_modes = {},      -- Disable hybrid mode by default
        debounce = 50,
        -- Prevent heading cut-off by ensuring consistent rendering
        draw_range = { vim.o.lines, vim.o.lines },
      },

      -- Markdown block-level elements
      markdown = {
        enable = true,

        -- Headings configuration
        headings = {
          enable = true,
          shift_width = 0,
          heading_1 = {
            style = 'icon',
            sign = '󰫎 ',  -- H1 sign
            icon = '󰉋 ',  -- H1 icon
          },
          heading_2 = {
            style = 'icon',
            sign = '󰫎 ',
            icon = '󰉌 ',
          },
          heading_3 = {
            style = 'icon',
            sign = '󰫎 ',
            icon = '󰉏 ',
          },
          heading_4 = {
            style = 'icon',
            sign = '󰫎 ',
            icon = '󰉑 ',
          },
          heading_5 = {
            style = 'icon',
            sign = '󰫎 ',
            icon = '󰉒 ',
          },
          heading_6 = {
            style = 'icon',
            sign = '󰫎 ',
            icon = '󰉓 ',
          },
        },

        -- Code blocks
        code_blocks = {
          enable = true,
          style = 'language',
          hl_mode = 'blend',
          min_width = 60,
          pad_amount = 2,
        },

        -- Lists and checkboxes
        list_items = {
          enable = true,
          indent_size = 2,
          shift_width = 2,
          add_padding = true,
        },

        -- Tables
        tables = {
          enable = true,
          style = 'full',  -- 'none', 'simple', 'full'
        },

        -- Block quotes
        block_quotes = {
          enable = true,
        },

        -- Horizontal rules
        horizontal_rules = {
          enable = true,
        },
      },

      -- Markdown inline elements
      markdown_inline = {
        enable = true,

        -- **4-STATE CHECKBOX CONFIGURATION** - This is the main feature we need!
        checkboxes = {
          enable = true,

          -- [ ] = Pending/Unchecked
          unchecked = {
            text = '󰄱 ',  -- NerdFont circle outline
            hl = 'MarkviewCheckboxUnchecked',
            scope_hl = 'MarkviewCheckboxUnchecked',
          },

          -- [-] = In Progress
          ["-"] = {
            text = '󰔛 ',  -- NerdFont clock
            hl = 'MarkviewCheckboxProgress',
            scope_hl = 'MarkviewCheckboxProgress',
          },

          -- [x] = Checked/Done
          checked = {
            text = '󰄵 ',  -- NerdFont check circle
            hl = 'MarkviewCheckboxChecked',
            scope_hl = 'MarkviewCheckboxChecked',
          },

          -- [_] = Cancelled **THE FIX FOR YOUR ISSUE!**
          ["_"] = {
            text = '󰅰 ',  -- NerdFont xmark/cancel
            hl = 'MarkviewCheckboxCancelled',
            scope_hl = 'MarkviewCheckboxCancelled',
          },
        },

        -- Inline code
        inline_codes = {
          enable = true,
          icon = '',  -- No icon, just highlight
        },

        -- Links
        hyperlinks = {
          enable = true,
          icon = '󰌹 ',  -- Link icon
        },

        -- Images
        images = {
          enable = true,
          icon = '󰥶 ',  -- Image icon
        },

        -- Email links
        emails = {
          enable = true,
          icon = '󰀓 ',  -- Email icon
        },
      },

      -- LaTeX support (optional but nice to have)
      latex = {
        enable = false,  -- Can enable if you use LaTeX math
      },

      -- HTML support
      html = {
        enable = true,
      },

      -- YAML frontmatter support
      yaml = {
        enable = true,

        -- Custom renderer to replace list item bullets with icons
        renderers = {
          yaml_property = function (ns, buffer, item)
            -- Get the property configuration to handle property icons
            local spec = require("markview.spec")
            local utils = require("markview.utils")

            local main_config = spec.get({ "yaml", "properties" }, { fallback = nil })
            if not main_config then
              return
            end

            local config = utils.match(main_config, item.key, { eval_args = { buffer, item } })
            if not config then
              return
            end

            -- Handle data type merging if use_types is true
            if config.use_types == true then
              config = vim.tbl_extend("force", spec.get(
                { "data_types", item.type },
                { source = main_config, eval_args = { buffer, item } }
              ), config)
            end

            -- Add property icon to the first line
            vim.api.nvim_buf_set_extmark(buffer, ns, item.range.row_start, item.range.col_start, {
              virt_text_pos = "inline",
              virt_text = { { config.text or "", utils.set_hl(config.hl) } }
            })

            -- For list-type properties, replace "-" bullets with icons
            if item.type == "list" then
              local property_icons = {
                tags = "󰓹 ",
                aliases = "󰷢 ",
                categories = "󰓪 ",
                cssclass = "󰌝 ",
                cssclasses = "󰌝 ",
              }

              local list_icon = property_icons[item.key] or "• "

              for i = item.range.row_start + 1, item.range.row_end do
                local line_text = item.text[i - item.range.row_start + 1]
                local bullet_start = line_text:match("^%s*()%-")
                if bullet_start then
                  local bullet_end = line_text:find("%-", bullet_start) + 1
                  vim.api.nvim_buf_set_extmark(buffer, ns, i, bullet_start - 1, {
                    virt_text_pos = "overlay",
                    virt_text = { { list_icon, config.hl or "Special" } },
                    end_col = bullet_end
                  })
                end
              end
            end
          end,
        },

        -- Custom icons and styling for common YAML properties
        properties = {
          -- Basic metadata
          title = {
            use_types = false,  -- Don't use data type icons, use this property's icon
            text = ' 󰉼 ',
            hl = 'MarkviewYamlTitle',
          },
          date = {
            use_types = false,
            text = ' 󰃭 ',
            hl = 'MarkviewYamlDate',
          },
          created = {
            use_types = false,
            text = ' 󰃮 ',
            hl = 'MarkviewYamlDate',
          },
          updated = {
            use_types = false,
            text = ' 󰔧 ',
            hl = 'MarkviewYamlDate',
          },
          tags = {
            use_types = false,
            text = ' 󰓹 ',
            hl = 'MarkviewYamlTags',
          },
          aliases = {
            use_types = false,
            text = ' 󰷢 ',
            hl = 'MarkviewYamlAliases',
          },
          status = {
            use_types = false,
            text = ' 󰔟 ',
            hl = 'MarkviewYamlStatus',
          },
          category = {
            use_types = false,
            text = ' 󰓪 ',
            hl = 'MarkviewYamlCategory',
          },
          categories = {
            use_types = false,
            text = ' 󰓪 ',
            hl = 'MarkviewYamlCategory',
          },
          author = {
            use_types = false,
            text = ' 󰛀 ',
            hl = 'MarkviewYamlAuthor',
          },
          description = {
            use_types = false,
            text = ' 󰊿 ',
            hl = 'MarkviewYamlDescription',
          },
          publish = {
            use_types = false,
            text = ' 󰈈 ',
            hl = 'MarkviewYamlPublish',
          },
          permalink = {
            use_types = false,
            text = ' 󰌷 ',
            hl = 'MarkviewYamlLink',
          },
          image = {
            use_types = false,
            text = ' 󰥶 ',
            hl = 'MarkviewYamlImage',
          },
          images = {
            use_types = false,
            text = ' 󰥶 ',
            hl = 'MarkviewYamlImage',
          },
          cover = {
            use_types = false,
            text = ' 󰋮 ',
            hl = 'MarkviewYamlImage',
          },
          cssclass = {
            use_types = false,
            text = ' 󰌝 ',
            hl = 'MarkviewYamlClass',
          },
          cssclasses = {
            use_types = false,
            text = ' 󰌝 ',
            hl = 'MarkviewYamlClass',
          },
          type = {
            use_types = false,
            text = ' 󰈂 ',
            hl = 'MarkviewYamlType',
          },
          version = {
            use_types = false,
            text = ' 󰗹 ',
            hl = 'MarkviewYamlVersion',
          },
          time_logs = {
            use_types = false,
            text = ' 󰔔 ',
            hl = 'MarkviewYamlSpecial',
          },
        },

        -- Scope decoration (visual styling around properties)
        use_separator = true,
      },

      -- Custom highlight groups (matching your colorscheme)
      highlight_groups = {
        -- These will automatically adapt to your colorscheme
        -- Markview creates dynamic palettes
      },
    }
  end,
  -- Load after colorscheme to ensure correct highlights
  config = function(_, opts)
    require('markview').setup(opts)
    -- Markview automatically attaches to filetypes listed in preview.filetypes
    -- Note: foldtext is set by markdown-enhancements.lua
  end,
}
