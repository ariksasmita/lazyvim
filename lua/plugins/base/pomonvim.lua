return {
  "epwalsh/pomo.nvim",
  version = "*",  -- Recommended, use latest release instead of latest commit
  lazy = true,
  cmd = { "TimerStart", "TimerRepeat", "TimerSession" },
   dependencies = {
     -- Optional, but highly recommended if you want to use the "Default" timer
     {
       "rcarriga/nvim-notify",
       opts = {
         top_down = false, -- Place notifications at bottom
       },
     },
   },
  opts = {
    -- How often the notifiers are updated (in milliseconds)
    update_interval = 1000,
    
    -- Configure the default notifiers to use for each timer
    notifiers = {
      -- Use the "Default" notifier if you want a simple UI like `tmux-pomodoro-plus`
      {
        name = "Default",
        opts = {
          -- Show a sticky notification when the timer is done
          sticky = true,
          -- Show the timer name in the notification title
          title_icon = "󱎫",
          text_icon = "󰔛",
        },
      },
    },
    
    -- Called when a timer completes
    on_complete = function(data)
      local timer_name = data.name or ""
      local timer_time = data.time_limit or 0
      
      -- Determine if this is a work session or rest based on timer duration
      -- Work sessions are typically 25 minutes (1500 seconds)
      -- Short rest is 5 minutes (300 seconds)
      -- Long rest is 10 minutes (600 seconds)
      local is_work_session = timer_time >= 1200 -- 20+ minutes = work session
      
      if is_work_session then
        -- Play a pleasant completion sound for work sessions
        vim.fn.system("afplay /System/Library/Sounds/Glass.aiff")
        vim.notify(
          string.format("Work session complete! Time for a break. 🎉\nTimer: %s", timer_name),
          vim.log.levels.INFO,
          { title = "Pomodoro Complete" }
        )
      else
        -- Play a different sound for rest completion
        vim.fn.system("afplay /System/Library/Sounds/Purr.aiff")
        vim.notify(
          string.format("Break complete! Ready to focus again. 💪\nTimer: %s", timer_name),
          vim.log.levels.INFO,
          { title = "Break Complete" }
        )
      end
    end,
  },
}
