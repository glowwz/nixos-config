local M = {}

local function get_venv(variable)
	local venv = os.getenv(variable)
	if venv ~= nil and string.find(venv, "/") then
		local orig_venv = venv
		for w in orig_venv:gmatch("([^/]+)") do
			venv = w
		end
		venv = string.format("%s", venv)
	end
	return venv
end

local _os_icon_cache = nil

local function _get_os_icon()
	if _os_icon_cache then
		return _os_icon_cache
	end

	local sysname = vim.uv.os_uname().sysname
	if sysname == "Windows_NT" or sysname:find("Windows") then
		_os_icon_cache = "󰨡"
		return _os_icon_cache
	elseif sysname == "Darwin" then
		_os_icon_cache = ""
		return _os_icon_cache
	end

	local distro_icons = {
		arch = "",
		gentoo = "󰣨",
		manjaro = "󰦫",
		ubuntu = "",
		debian = "",
		fedora = "",
		opensuse = "",
		nixos = "",
		void = "",
		mint = "󰣭",
		pop = "",
		endeavouros = "",
		alpine = "",
		centos = "󱄚",
		kali = "",
		artix = "",
	}

	local f = io.open("/etc/os-release", "r")
	if f then
		local file_content = f:read("*a")
		f:close()
		local id = file_content:match("\nID=([^\n]*)") or file_content:match("^ID=([^\n]*)")
		if id then
			id = id:gsub('"', ""):lower()
			if distro_icons[id] then
				_os_icon_cache = distro_icons[id]
				return _os_icon_cache
			end
		end
	end

	_os_icon_cache = "" -- Generic Linux fallback
	return _os_icon_cache
end

M.modules = {
	-- Override mode to remove trailing separator so arrow_diagnostics can attach directly
	mode = function()
		local utils = require("nvchad.stl.utils")
		if not utils.is_activewin() then
			return ""
		end
		local modes = utils.modes
		local m = vim.api.nvim_get_mode().mode
		local mode_name = modes[m][2]
		return "%#St_" .. mode_name .. "Mode# " .. _get_os_icon() .. " " .. modes[m][1] .. " "
	end,

	-- NOTE: Add colors to the git status

	-- git = function()
	--   local stbufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
	--   if not vim.b[stbufnr].gitsigns_head or vim.b[stbufnr].gitsigns_git_status then
	--     return ""
	--   end
	--
	--   local git_status = vim.b[stbufnr].gitsigns_status_dict
	--
	--   local added = (git_status.added and git_status.added ~= 0) and ("  " .. git_status.added) or ""
	--   local changed = (git_status.changed and git_status.changed ~= 0) and ("  " .. git_status.changed) or ""
	--   local removed = (git_status.removed and git_status.removed ~= 0) and ("  " .. git_status.removed) or ""
	--   local branch_name = " " .. git_status.head
	--
	--   return " "
	--     .. "%#St_gitIcons#"
	--     .. branch_name
	--     .. "%#GitSignsAdd#"
	--     .. added
	--     .. "%#GitSignsChange#"
	--     .. changed
	--     .. "%#GitSignsDelete#"
	--     .. removed
	-- end,

	arrow_diagnostics = function()
		local utils = require("nvchad.stl.utils")
		local config = require("nvconfig").ui.statusline
		local sep_style = config.separator_style
		local sep_icons = utils.separators
		local separators = (type(sep_style) == "table" and sep_style) or sep_icons[sep_style]
		local sep_r = separators["right"]

		local modes = utils.modes
		local m = vim.api.nvim_get_mode().mode

		-- Get the mode's bg color to transition directly from mode block
		local ok, mode_hl = pcall(vim.api.nvim_get_hl, 0, { name = "St_" .. modes[m][2] .. "Mode" })
		local mode_bg = (ok and mode_hl.bg) and string.format("#%06x", mode_hl.bg) or nil

		if not mode_bg then
			local ok2, stl_bg = pcall(vim.api.nvim_get_hl, 0, { name = "StatusLine" })
			mode_bg = (ok2 and stl_bg.bg) and string.format("#%06x", stl_bg.bg) or "NONE"
		end

		local segments = {
			{ bg = "#e06c75" }, -- red
			{ bg = "#e5c07b" }, -- yellow
			{ bg = "#61afef" }, -- blue
		}

		local result = ""
		local prev_bg = mode_bg

		for i, seg in ipairs(segments) do
			local sep_hl = "St_arrow_sep_" .. i
			local txt_hl = "St_arrow_txt_" .. i
			vim.api.nvim_set_hl(0, sep_hl, { fg = prev_bg, bg = seg.bg })
			vim.api.nvim_set_hl(0, txt_hl, { fg = seg.bg, bg = seg.bg })
			result = result .. "%#" .. sep_hl .. "#" .. sep_r .. "%#" .. txt_hl .. "#" .. ""
			prev_bg = seg.bg
		end

		-- Transition last arrow into St_file bg to avoid gap
		local ok_file, file_hl = pcall(vim.api.nvim_get_hl, 0, { name = "St_file" })
		local next_bg = (ok_file and file_hl.bg) and string.format("#%06x", file_hl.bg) or nil

		if not next_bg then
			local ok3, stl_bg = pcall(vim.api.nvim_get_hl, 0, { name = "StatusLine" })
			next_bg = (ok3 and stl_bg.bg) and string.format("#%06x", stl_bg.bg) or "NONE"
		end

		local end_hl = "St_arrow_sep_end"
		vim.api.nvim_set_hl(0, end_hl, { fg = prev_bg, bg = next_bg })
		result = result .. "%#" .. end_hl .. "#" .. sep_r

		return result
	end,

	total_lines = function()
		local separators = {}
		local config = require("nvconfig").ui.statusline
		local theme = config.theme
		local sep_style = config.separator_style

		local mode = {
			default = {
				default = { left = "", right = "" },
				round = { left = "", right = "" },
				block = { left = "█", right = "█" },
				arrow = { left = "", right = "" },
			},
			minimal = {
				default = { left = "█", right = "█" },
				round = { left = "", right = "" },
				block = { left = "█", right = "█" },
				arrow = { left = "█", right = "█" },
			},
			vscode = {
				default = { left = "█", right = "█" },
				round = { left = "", right = "" },
				block = { left = "█", right = "█" },
				arrow = { left = "", right = "" },
			},
			vscode_colored = {
				default = { left = "█", right = "█" },
				round = { left = "", right = "" },
				block = { left = "█", right = "█" },
				arrow = { left = "", right = "" },
			},
		}

		separators = (type(sep_style) == "table" and sep_style) or mode[theme][sep_style]

		local sep_l = separators["left"]
		local sep_end = "%#St_sep_r#" .. separators["right"]

		-- From: NvChad/ui
		local function gen_block(icon, txt, sep_l_hlgroup, iconHl_group, txt_hl_group)
			return sep_l_hlgroup .. sep_l .. iconHl_group .. icon .. "" .. txt_hl_group .. " " .. txt .. sep_end
		end

		if theme == "default" then
			return "%#St_pos_sep#" .. sep_l .. "%#St_pos_icon# %#St_pos_text# %p %% "
		elseif theme == "vscode" or theme == "vscode_colored" then
			return "%#StText# %L "
		end
		return gen_block("", "%L", "%#St_Pos_sep#", "%#St_Pos_bg#", "%#St_Pos_txt#")
	end,

	harpoon = function()
		-- simplified version of this https://github.com/letieu/harpoon-lualine
		local options = {
			icon = "󰀱 ",
			indicators = { "1", "2", "3", "4" },
			active_indicators = { "[1]", "[2]", "[3]", "[4]" },
			separator = " ",
		}
		local list = require("harpoon"):list()
		local root_dir = list.config:get_root_dir()
		local current_file_path = vim.api.nvim_buf_get_name(0)

		local length = math.min(list:length(), #options.indicators)

		local status = {}
		local get_full_path = function(root, value)
			return root .. vim.g.path_separator .. value
		end

		for i = 1, length do
			local value = list:get(i).value
			local full_path = get_full_path(root_dir, value)

			if full_path == current_file_path then
				table.insert(status, options.active_indicators[i])
			else
				table.insert(status, options.indicators[i])
			end
		end

		return table.concat(status, options.separator)
	end,

	python_venv = function()
		if vim.bo.filetype ~= "python" then
			return " "
		end

		local venv = get_venv("CONDA_DEFAULT_ENV") or get_venv("VIRTUAL_ENV") or " "
		if venv == " " then
			return " "
		else
			return "  " .. venv
		end
	end,

	debug_status = function()
		local status = require("dap").status()
		if status ~= "" then
			return "  " .. status
		else
			return ""
		end
	end,

	command = function()
		local noice_ok, noice = pcall(require, "noice.api")
		if noice_ok and noice.status.command.has() then
			return " %#St_gitIcons#" .. noice.status.command.get() .. " "
		else
			return " "
		end
	end,

	lazy_updates = function()
		local updates = require("lazy.status").updates()
		if updates then
			return updates .. " "
		else
			return ""
		end
	end,

	os_icon = function()
		local bg = vim.o.background
		local fg = bg == "light" and "black" or "white"
		vim.api.nvim_set_hl(0, "St_os_icon", { fg = fg, bg = "NONE" })
		return " %#St_os_icon#" .. _get_os_icon() .. " "
	end,

	spotify = function()
		-- Primero intenta integration.nvim (unificado), luego spotify.nvim (legacy)
		local ok, mod = pcall(require, "integration")
		if ok then
			return mod.statusline()
		end
		local ok2, spotify = pcall(require, "spotify")
		if ok2 then
			return spotify.statusline()
		end
		return ""
	end,

	clients = function()
		local buf = vim.api.nvim_get_current_buf()

		-- Preallocate small tables
		local clients = {}
		local added = {} -- For deduplication (faster than vim.tbl_contains)

		-- Collect LSP clients
		local lsp_clients = vim.lsp.get_clients({ bufnr = buf })
		for i = 1, #lsp_clients do
			local name = lsp_clients[i].name
			clients[#clients + 1] = name
			added[name] = true
		end

		-- Collect linters (if available)
		local ok_lint, lint = pcall(require, "lint")
		if ok_lint then
			local linters_by_ft = lint.linters_by_ft
			if linters_by_ft then
				for ft in vim.gsplit(vim.bo.filetype, ".", { plain = true, trimempty = true }) do
					local linters = linters_by_ft[ft]
					if linters then
						for j = 1, #linters do
							local name = linters[j]
							if not added[name] then
								clients[#clients + 1] = name
								added[name] = true
							end
						end
					end
				end
			end
		end

		-- Collect formatters (if available)
		local ok_conform, conform = pcall(require, "conform")
		if ok_conform and conform.list_formatters then
			local formatters = conform.list_formatters(0)
			for i = 1, #formatters do
				local name = formatters[i].name
				if not added[name] then
					clients[#clients + 1] = name
					added[name] = true
				end
			end
		end

		local count = #clients
		if count == 0 then
			return ""
		end

		if vim.o.columns > 100 then
			return " %#St_gitIcons#" .. table.concat(clients, ", ") .. " "
		else
			return "  LSP "
		end
	end,
}

return M
