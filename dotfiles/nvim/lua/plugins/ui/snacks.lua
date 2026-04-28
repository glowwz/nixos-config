---@type LazySpec
-- NOTE: QoL Plugins
local headers = require("config.statusline.headers")

-- OS-aware paths for dashboard commands
local is_windows = vim.g.is_windows
local config_dir = vim.fn.stdpath("config")
local gif_path = config_dir .. "/lua/plugins/sylveon1.gif" -- if u wanna change gifs
-- Normalize path separators for shell commands
local gif_path_shell = is_windows and gif_path:gsub("/", "\\") or gif_path
-- animation with lolcrab, personally if u wanna change it test with lolcat
-- this workly windows and linux, windows animation.cmd and linux animation.sh
local animation_cmd
local header_path = config_dir .. "/lua/config/statusline/header.txt"
if is_windows then
  local anim_script = (config_dir .. "/lua/config/statusline/animation.cmd"):gsub("/", "\\")
  local header_win = header_path:gsub("/", "\\")
  -- cmd.exe /s /c wraps the entire command; avoid nested double-quotes
  animation_cmd = anim_script .. " " .. header_win
else
  animation_cmd = "bash " .. config_dir .. "/lua/config/statusline/animation.sh " .. header_path
end
-- chafa with Linux and Windows :d
local chafa_cmd
if is_windows then
  -- On Windows, chafa is available via WinGet; use cmd-compatible syntax
  -- & pause >nul keeps the terminal alive (equivalent to ; sleep on Linux)
  chafa_cmd = "chafa -f symbols -c full --speed=0.8 --clear --stretch " .. gif_path_shell .. " & pause >nul"
else
  chafa_cmd = "chafa -f symbols -c full --speed=0.8 --clear --stretch " .. gif_path .. "; sleep"
end

return {
  "folke/snacks.nvim",
  priority = 9999,
  lazy = false,
  init = function()
    vim.api.nvim_set_hl(0, "SnacksDashboardDir", { fg = "#ced4df" })
  end,
  keys = {
    {
      "<leader>n",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },
  },
  -- { "3rd/image.nvim", opts = { backend = "kitty" } }, -- imgs
  opts = {
    explorer = { enabled = false },
    dashboard = {
      width = 60,
      pane_gap = 16,
      sections = {
        {
          enabled = function()
            return not (vim.o.columns > 110)
          end,
          section = "terminal",
          cmd = animation_cmd,
          height = 12,
          width = 72,
          align = "center",
          indent = -10,
          padding = 2,
        },
        -- gif/img on dashboard
        {
          pane = 1,
          enabled = function()
            return vim.o.columns > 110
          end,
          section = "terminal",
          cmd = chafa_cmd,
          height = 35,
          width = 60,
          ttl = 0,
          padding = 2,
          lazy = false,
        }, -- pane
        {
          pane = 2,
          { section = "keys", gap = 0, padding = 2 },
          { icon = " ", title = "Recent Files" },
          { section = "recent_files", opts = { limit = 3 }, indent = 2, padding = 1 },
          { icon = " ", title = "Projects" },
          { section = "projects", opts = { limit = 3 }, indent = 2, padding = 1 },
          { section = "startup", padding = 1 },
        },
      },
      preset = {
        -- header = table.concat(headers.hydra, "\n"),-- uses this if u gonna change with normal ascii art instead animation with lolcrab
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          {
            icon = "󱁤 ",
            key = "g",
            desc = "Find Text",
            action = ":lua Snacks.dashboard.pick('live_grep')",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          {
            icon = "󰒲 ",
            key = "L",
            desc = "Lazy",
            action = ":Lazy",
            enabled = package.loaded.lazy ~= nil,
          },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󱁤 ", key = "m", desc = "Mason", action = ":Mason" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
  },
}
