return {
	"lvim-tech/lvim-dependencies",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"lvim-tech/lvim-utils",
	},
	config = function()
		require("lvim-dependencies").setup({
			-- your configuration here
		})
	end,
}
