return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	config = function()
		pcall(dofile, vim.g.base46_cache .. "trouble")
		require("trouble").setup()
	end,
}
