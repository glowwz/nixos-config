-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local utils = require("config.utils")

-- Yank All Text
vim.keymap.set("n", "<leader>y", "<cmd>%y+<cr>", { desc = "Yank All Text", silent = true })

-- Delete All Text
vim.keymap.set("n", "<leader>bR", "<cmd>%d+<cr>", { desc = "Remove All Text", silent = true })

-- Save With Root
vim.keymap.set("n", "<leader>bs", "<cmd>SudaWrite<cr>", { desc = "Save With Root", silent = true })

-- Run Code
vim.keymap.set("n", "<leader>ce", function()
	utils.run_code()
end, { desc = "Execute Code", silent = true })

-- Project Bootstrap
vim.keymap.set("n", "<leader>P", function()
	utils.bootstrap_project()
end, { desc = "Project Bootstrap", silent = true })

-- lazy
vim.keymap.set("n", "<leader>lh", "<cmd>Lazy<cr>", { desc = "Lazy Home" })
vim.keymap.set("n", "<leader>le", "<cmd>LazyExtras<cr>", { desc = "Lazy Extras" })
vim.keymap.set("n", "<leader>ls", "<cmd>Lazy sync<cr>", { desc = "Lazy Sync" })
vim.keymap.set("n", "<leader>lu", "<cmd>Lazy update<cr>", { desc = "Lazy Update" })
vim.keymap.set("n", "<leader>lL", "<cmd>Lazy log<cr>", { desc = "Lazy Log" })
vim.keymap.set("n", "<leader>lc", "<cmd>Lazy clean<cr>", { desc = "Lazy Clean" })
vim.keymap.set("n", "<leader>lp", "<cmd>Lazy profile<cr>", { desc = "Lazy Profile" })
vim.keymap.set("n", "<leader>li", "<cmd>Lazy install<cr>", { desc = "Lazy Install" })
vim.keymap.set("n", "<leader>ll", function()
	local keys = vim.api.nvim_replace_termcodes(":Lazy load ", true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "Load Plugin" })
vim.keymap.set("n", "<leader>lH", "<cmd>Lazy help<cr>", { desc = "Lazy Help" })
vim.keymap.set("n", "<leader>ld", "<cmd>Lazy debug<cr>", { desc = "Lazy Debug" })

-- From: https://medium.com/@musickcorym/fixing-the-lag-why-i-ditched-vim-tmux-navigator-for-a-faster-plugin-free-setup-239da138e4aa
local function smart_move(direction, tmux_cmd)
	local curwin = vim.api.nvim_get_current_win()
	vim.cmd("wincmd " .. direction)
	if curwin == vim.api.nvim_get_current_win() then
		vim.fn.system("tmux select-pane " .. tmux_cmd)
	end
end

vim.keymap.set("n", "<C-h>", function()
	smart_move("h", "-L")
end, { silent = true })
vim.keymap.set("n", "<C-j>", function()
	smart_move("j", "-D")
end, { silent = true })
vim.keymap.set("n", "<C-k>", function()
	smart_move("k", "-U")
end, { silent = true })
vim.keymap.set("n", "<C-l>", function()
	smart_move("l", "-R")
end, { silent = true })

vim.keymap.set("n", "<leader>uH", function()
	if vim.g.transparent_enabled then
		vim.cmd("colorscheme " .. (vim.g.colors_name or "aether"))
		vim.g.transparent_enabled = false
	else
		local groups = {
			"Normal", "NormalNC", "NormalFloat", "FloatBorder", "FloatTitle",
			"SignColumn", "LineNr", "LineNrAbove", "LineNrBelow",
			"CursorLine", "CursorLineNr", "CursorLineSign", "CursorLineFold",
			"EndOfBuffer", "FoldColumn", "Folded",
			"StatusLine", "StatusLineNC",
			"TabLine", "TabLineFill", "TabLineSel",
			"WinSeparator", "WinBar", "WinBarNC",
			"Pmenu", "PmenuSel", "PmenuSbar", "PmenuThumb",
			"NvimTreeNormal", "NvimTreeNormalNC",
			"NeoTreeNormal", "NeoTreeNormalNC",
		}
		for _, group in ipairs(groups) do
			vim.cmd("hi " .. group .. " guibg=NONE ctermbg=NONE")
		end
		vim.g.transparent_enabled = true
	end
end, { desc = "Toggle Transparency" })

vim.keymap.set("n", "<leader>uC", function()
	if vim.g.colorscheme == "nvchad" then
		local ok, utils = pcall(require, "config.utils")
		if ok and utils.theme_picker then
			require("nvchad.themes").open()
		end
	else
		require("snacks").picker.colorschemes()
	end
end, { desc = "Colorschemes" })
