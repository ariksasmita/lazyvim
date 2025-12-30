-- Configure winbar to display breadcrumbs at the top
return {
  -- Keep nvim-navic configuration from setup.lua
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    init = function()
      vim.g.navic_silence = true
      
      -- Throttle timer for performance
      local update_timer = nil
      
      local function update_winbar()
        -- Skip winbar for certain filetypes and special buffers
        local filetype = vim.bo.filetype
        local buftype = vim.bo.buftype
        local ignore_filetypes = { 
          "help", "neo-tree", "Trouble", "lazy", "mason", "notify", 
          "toggleterm", "lazyterm", "TelescopePrompt", "TelescopeResults",
          "noice", "snacks_dashboard", "snacks_notif", "snacks_terminal",
          "snacks_win"
        }
        
        -- Skip for special buffer types (terminal, quickfix, etc.)
        if buftype ~= "" then
          vim.opt_local.winbar = nil
          return
        end
        
        -- Skip for ignored filetypes
        if vim.tbl_contains(ignore_filetypes, filetype) then
          vim.opt_local.winbar = nil
          return
        end
        
        -- Skip for unnamed/scratch buffers
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname == "" or bufname:match("^%[") then
          vim.opt_local.winbar = nil
          return
        end
        
        -- Only set winbar if window has enough height
        if vim.api.nvim_win_get_height(0) < 4 then
          vim.opt_local.winbar = nil
          return
        end
        
        local navic = require("nvim-navic")
        if navic.is_available() then
          -- Get lualine's actual background color for better matching
          local lualine_c_hl = vim.api.nvim_get_hl(0, { name = "lualine_c_normal" })
          if lualine_c_hl and lualine_c_hl.bg then
            -- Create custom winbar highlight that matches lualine exactly
            vim.api.nvim_set_hl(0, "WinBarCustom", {
              fg = lualine_c_hl.fg or vim.api.nvim_get_hl(0, { name = "Normal" }).fg,
              bg = lualine_c_hl.bg,
            })
            vim.opt_local.winbar = "%#WinBarCustom#  %{%v:lua.require'nvim-navic'.get_location()%}"
          else
            -- Fallback to StatusLine if lualine color not available
            vim.opt_local.winbar = "%#StatusLine#  %{%v:lua.require'nvim-navic'.get_location()%}"
          end
        else
          -- Don't show winbar if no breadcrumbs available
          vim.opt_local.winbar = nil
        end
      end
      
      -- Set up winbar to display breadcrumbs with throttling
      vim.api.nvim_create_autocmd({ "CursorMoved" }, {
        callback = function()
          -- Throttle updates on CursorMoved to avoid lag
          if update_timer then
            update_timer:stop()
          end
          update_timer = vim.defer_fn(update_winbar, 100) -- 100ms debounce
        end,
      })
      
      -- Immediate update for these events
      vim.api.nvim_create_autocmd({ "BufWinEnter", "BufFilePost", "LspAttach" }, {
        callback = update_winbar,
      })
      
      -- Also update on session restore and after telescope opens files
      vim.api.nvim_create_autocmd({ "BufReadPost", "SessionLoadPost" }, {
        callback = function()
          vim.defer_fn(update_winbar, 200)
          vim.defer_fn(update_winbar, 500)
        end,
      })
      
      -- Special handling for session restore - update all buffers
      vim.api.nvim_create_autocmd("SessionLoadPost", {
        callback = function()
          vim.defer_fn(function()
            -- Update winbar for all visible buffers
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              vim.api.nvim_win_call(win, update_winbar)
            end
          end, 1000)
        end,
      })
      
      -- Attach navic to LSP
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("NavicAttach", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, args.buf)
          end
        end,
      })
      
      -- Set up winbar colors to ensure visibility
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- Trigger winbar update after colorscheme changes
          vim.defer_fn(update_winbar, 50)
        end,
      })
    end,
    opts = function()
      return {
        separator = " > ",
        highlight = false, -- Disable navic's own highlighting so we can control colors
        depth_limit = 5,
        icons = require("lazyvim.config").icons.kinds,
        lazy_update_context = true,
      }
    end,
    config = function(_, opts)
      require("nvim-navic").setup(opts)
      
      -- Override all navic highlight groups to match lualine
      local function set_navic_highlights()
        local lualine_c_hl = vim.api.nvim_get_hl(0, { name = "lualine_c_normal" })
        if lualine_c_hl and lualine_c_hl.bg then
          local hl_groups = {
            "NavicIconsFile", "NavicIconsModule", "NavicIconsNamespace", "NavicIconsPackage",
            "NavicIconsClass", "NavicIconsMethod", "NavicIconsProperty", "NavicIconsField",
            "NavicIconsConstructor", "NavicIconsEnum", "NavicIconsInterface", "NavicIconsFunction",
            "NavicIconsVariable", "NavicIconsConstant", "NavicIconsString", "NavicIconsNumber",
            "NavicIconsBoolean", "NavicIconsArray", "NavicIconsObject", "NavicIconsKey",
            "NavicIconsNull", "NavicIconsEnumMember", "NavicIconsStruct", "NavicIconsEvent",
            "NavicIconsOperator", "NavicIconsTypeParameter", "NavicText", "NavicSeparator"
          }
          
          for _, group in ipairs(hl_groups) do
            vim.api.nvim_set_hl(0, group, {
              fg = lualine_c_hl.fg,
              bg = lualine_c_hl.bg,
            })
          end
        end
      end
      
      -- Set highlights on colorscheme change
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_navic_highlights,
      })
      
      -- Set highlights immediately
      set_navic_highlights()
    end,
  },
}
