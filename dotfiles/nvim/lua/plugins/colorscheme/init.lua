-- since this is just an example spec, don't actually load anything here and return an empty spec
-- if true then return {} end

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
	{
		"LazyVim/LazyVim",
		opts = function(_, opts)
			opts.colorscheme = vim.g.colorscheme

			-- Always load base46 cache for NvChad UI components (statusline, tabufline, etc.)
			for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
				dofile(vim.g.base46_cache .. v)
			end
		end,
	},
}
