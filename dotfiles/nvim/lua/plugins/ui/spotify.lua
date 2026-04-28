---@type LazySpec
-- NOTE: Spotify statusline integration (local plugin)
-- DEPRECATED: Reemplazado por integration.lua que soporta multiples players.
-- Se mantiene deshabilitado como referencia. Para reactivar, cambiar enabled = true
-- y deshabilitar integration.lua para evitar conflictos.
return {
  {
    dir = vim.fn.expand("~/integration/spotify.nvim"),
    name = "spotify.nvim",
    enabled = false, -- deshabilitado: ahora se usa integration.nvim
    event = "VeryLazy",
    config = function()
      require("spotify").setup({
        icon = "󰓇",
        -- Intervalo de refresco en milisegundos
        refresh_interval = 5000,

        max_length = 45,

        -- cmd = {
        --   windows = { "powershell", "-c", "..." },
        --   linux   = { "playerctl", ... },
        --   darwin  = { "sh", "-c", "..." },
        -- },
      })
    end,
  },
}
