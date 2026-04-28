local generated_dir = vim.fn.expand("~/.local/state/quickshell/user/generated")
local palette_file = generated_dir .. "/palette.json"
local terminal_file = generated_dir .. "/terminal.json"
local legacy_colors_file = generated_dir .. "/colors.json"

local function read_json(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or not lines or vim.tbl_isempty(lines) then
    return {}
  end

  local ok_decode, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok_decode or type(decoded) ~= "table" then
    return {}
  end

  return decoded
end

local function load_inir_colors()
  local palette = read_json(palette_file)
  if vim.tbl_isempty(palette) then
    palette = read_json(legacy_colors_file)
  end
  local terminal = read_json(terminal_file)

  local function pick(tbl, key, fallback)
    local value = tbl[key]
    return type(value) == "string" and value ~= "" and value or fallback
  end

  local fg = pick(palette, "on_background", "#E8E1DE")
  local blue = pick(terminal, "term4", "#B19FB6")
  local yellow = pick(terminal, "term11", "#E2CBB5")

  return {
    bg = pick(palette, "background", "#151311"),
    dark_bg = pick(palette, "surface_container_low", "#1E1B19"),
    darker_bg = pick(palette, "surface_container_lowest", "#100D0C"),
    lighter_bg = pick(palette, "surface_container_highest", "#383432"),

    fg = fg,
    dark_fg = pick(palette, "on_surface_variant", "#CFC4BD"),
    light_fg = pick(terminal, "term15", fg),
    bright_fg = pick(palette, "inverse_surface", fg),
    muted = pick(palette, "outline", "#998F88"),

    red = pick(terminal, "term1", "#CA917F"),
    yellow = yellow,
    orange = pick(palette, "primary", "#F3D9C5"),
    green = pick(terminal, "term2", "#BBBB97"),
    cyan = pick(terminal, "term6", "#B5C8AA"),
    blue = blue,
    purple = pick(terminal, "term5", "#BF9EA4"),
    brown = pick(palette, "secondary_container", "#50443B"),

    bright_red = pick(terminal, "term9", "#DDB2A6"),
    bright_yellow = yellow,
    bright_green = pick(terminal, "term10", "#D4D4B0"),
    bright_cyan = pick(terminal, "term14", "#D6E9CA"),
    bright_blue = pick(terminal, "term12", "#D2C0D9"),
    bright_purple = pick(terminal, "term13", "#E0BFC6"),

    accent = pick(palette, "primary", blue),
    cursor = fg,
    foreground = fg,
    background = pick(palette, "background", "#151311"),
    selection = pick(palette, "surface_container_high", "#2D2928"),
    selection_foreground = fg,
    selection_background = pick(palette, "surface_container_high", "#2D2928"),
  }
end

return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "inir-neovim",
    priority = 1000,
    opts = {
      colors = load_inir_colors(),
    },
    config = function(_, opts)
      local uv = vim.uv or vim.loop
      local watched_files = {
        ["palette.json"] = true,
        ["terminal.json"] = true,
        ["colors.json"] = true,
      }

      local function apply_inir_theme(next_opts)
        next_opts = vim.tbl_deep_extend("force", next_opts or {}, {
          colors = load_inir_colors(),
        })
        require("aether").setup(next_opts)
        vim.cmd.colorscheme("aether")
      end

      local function reload_inir_theme()
        if vim.g.colors_name ~= "aether" then
          return
        end

        apply_inir_theme(opts)
        vim.cmd("redraw!")
      end

      apply_inir_theme(opts)
      require("aether.hotreload").setup()

      if vim.g.inir_aether_watch_started == 1 or not uv then
        return
      end

      local reload_pending = false
      local watchers = {}

      local function schedule_reload()
        if reload_pending then
          return
        end

        reload_pending = true
        vim.defer_fn(function()
          reload_pending = false
          reload_inir_theme()
        end, 120)
      end

      local fs_event = uv.new_fs_event()
      if fs_event then
        fs_event:start(generated_dir, {}, function(err, fname)
          if err then
            return
          end
          if fname and not watched_files[fname] then
            return
          end
          schedule_reload()
        end)
        watchers[#watchers + 1] = fs_event
      end

      if #watchers == 0 then
        return
      end

      vim.g.inir_aether_watch_started = 1
      vim.__inir_aether_fs_events = watchers
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
