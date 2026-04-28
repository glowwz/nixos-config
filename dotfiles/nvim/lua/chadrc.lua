-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

local highlights = require("highlights")

M.base46 = {
  theme = "aquarium",
  transparency = false,
  hl_override = highlights.override,
  hl_add = highlights.add,
  changed_themes = {
    aquarium = {
      base_30 = {
        black = "#080a0b",
        darker_black = "#050708",
        black2 = "#0d0f10",
        one_bg = "#121415",
        one_bg2 = "#1c1e1f",
        one_bg3 = "#262829",
        statusline_bg = "#0c0e0f",
        lightbg = "#161819",
        line = "#151718",
      },
      base_16 = {
        base00 = "#080a0b",
        base01 = "#141617",
        base02 = "#252729",
        base03 = "#1f2123",
      },
    },
  },
}

M.ui = {
  telescope = { style = "bordered" },
  statusline = {
    enabled = true,
    theme = "vscode_colored", -- default/vscode/vscode_colored/minimal
    -- default/round/block/arrow separators work only for default statusline theme
    -- round and block will work for minimal theme only
    separator_style = "default",
    order = {
      "mode",
      "arrow_diagnostics",
      "file",
      "git",
      "%=",
      "spotify",
      "%=",
      "lsp_msg",
      "python_venv",
      "diagnostics",
      "debug_status",
      "command",
      "lazy_updates",
      -- "os_icon",
      -- "clients",
      "cwd",
      "total_lines",
    },
    modules = require("config.statusline").modules,
  },
  tabufline = {
    enabled = true,
    lazyload = true,
    order = { "treeOffset", "buffers", "tabs", "btns" },
    modules = require("config.tabufline").modules,
  },
  colorify = {
    enabled = true,
    mode = "virtual",
    virt_text = "󱓻 ",
    hightlight = { hex = true, lspvars = true },
  },
}

return M
