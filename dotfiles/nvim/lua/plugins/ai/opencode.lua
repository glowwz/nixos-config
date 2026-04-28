return {
	{
		"cajames/copy-reference.nvim",
		opts = {},
		keys = {
			{ "<leader>y", "<cmd>CopyReference file<cr>", mode = { "n", "v" } },
			{ "<leader>Y", "<cmd>CopyReference line<cr>", mode = { "n", "v" } },
		},
	},
	{
		"nickjvandyke/opencode.nvim",
		version = "*",
		dependencies = {
			{
				---@module "snacks"
				"folke/snacks.nvim",
				optional = true,
				opts = {
					input = {},
					picker = {
						actions = {
							opencode_send = function(...)
								return require("opencode").snacks_picker_send(...)
							end,
						},
						win = {
							input = {
								keys = {
									["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
								},
							},
						},
					},
				},
			},
		},
		config = function()
			---@type opencode.Opts
			vim.g.opencode_opts = {}

			vim.o.autoread = true

			local oc = require("opencode")

			-- Helper: focus the opencode terminal and enter insert mode
			local function focus_opencode_terminal()
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.bo[buf].buftype == "terminal" then
						local name = vim.api.nvim_buf_get_name(buf)
						if name:match("opencode") then
							vim.api.nvim_set_current_win(win)
							vim.cmd("startinsert")
							return
						end
					end
				end
			end

			-- Helper: check if opencode terminal exists
			local function opencode_terminal_exists()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.bo[buf].buftype == "terminal" then
						local name = vim.api.nvim_buf_get_name(buf)
						if name:match("opencode") then
							return true
						end
					end
				end
				return false
			end

			-- Ask: input first, then open terminal and submit
			vim.keymap.set({ "n", "x" }, "<leader>aa", function()
				Snacks.input({
					prompt = "Ask opencode",
					default = "@this: ",
					icon = "󰚩 ",
					win = {
						relative = "cursor",
						row = -3,
						col = 0,
						keys = {
							i_cr = { desc = "submit" },
							i_s_cr = {
								"<S-CR>",
								function(win)
									local text = win:text() .. "\\n"
									vim.api.nvim_buf_set_lines(win.buf, 0, -1, false, { text })
									win:execute("confirm")
								end,
								mode = "i",
								desc = "append",
							},
						},
						footer_keys = { "<CR>", "<S-CR>" },
					},
				}, function(input)
					if not input or input == "" then
						return
					end
					if not opencode_terminal_exists() then
						require("opencode.terminal").start("opencode --port")
						vim.defer_fn(function()
							oc.prompt(input, { submit = true })
							vim.defer_fn(focus_opencode_terminal, 500)
						end, 2500)
					else
						oc.prompt(input, { submit = true })
						vim.defer_fn(focus_opencode_terminal, 500)
					end
				end)
			end, { desc = "Ask about this" })

			-- Select prompts, commands, server controls
			vim.keymap.set({ "n", "x" }, "<leader>as", function()
				oc.select()
			end, { desc = "Select prompt" })

			-- Toggle opencode terminal
			vim.keymap.set({ "n", "t" }, "<leader>at", function()
				oc.toggle()
			end, { desc = "Toggle opencode" })

			-- Operator: add range context
			vim.keymap.set({ "n", "x" }, "<leader>ao", function()
				return oc.operator("@this ")
			end, { expr = true, desc = "Add range to opencode" })

			-- Session controls
			vim.keymap.set("n", "<leader>an", function()
				oc.command("session.new")
			end, { desc = "New session" })
			vim.keymap.set("n", "<leader>ai", function()
				oc.command("session.interrupt")
			end, { desc = "Interrupt session" })

			-- Navigation
			vim.keymap.set("n", "<leader>aA", function()
				oc.command("agent.cycle")
			end, { desc = "Cycle agent" })
			vim.keymap.set({ "n", "t" }, "<C-S-u>", function()
				oc.command("session.half.page.up")
			end, { desc = "Scroll opencode up" })
			vim.keymap.set({ "n", "t" }, "<C-S-d>", function()
				oc.command("session.half.page.down")
			end, { desc = "Scroll opencode down" })
		end,
	},
	{
		"folke/which-key.nvim",
		optional = true,
		opts = {
			spec = {
				{ "<leader>a", group = "AI" },
			},
		},
	},
}
