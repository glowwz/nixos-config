---@type LazySpec
-- NOTE: Music player statusline integration (unified plugin)
-- Soporta: Spotify, Apple Music/Cider, MusicBee
-- Reemplaza spotify.lua — spotify.nvim queda intacto como referencia
return {
  {
    dir = vim.fn.expand("~/integration/integration.nvim"),
    name = "integration.nvim",
    event = "VeryLazy",
    config = function()
      require("integration").setup({
        -- Deteccion automatica: prueba los players en orden de prioridad.
        -- El primero que este reproduciendo (o pausado) se muestra en la statusline.
        -- Cuando uno se cierra, cambia automaticamente al siguiente activo.
        players = { "spotify", "applemusic", "musicbee" },

        -- Intervalo de refresco en ms. 1000 recomendado para deteccion rapida
        -- de cambios de player y estado de pausa.
        refresh_interval = 1000,

        max_length = 45,

        -- Icono de pausa (se muestra en lugar del icono del player cuando esta pausado)
        -- pause_icon = "󰏤",

        -- Comandos custom por OS (nil = usar los builtins del player)
        -- cmd = {
        --   windows = { "powershell", "-c", "..." },
        --   linux   = { "playerctl", ... },
        --   darwin  = { "sh", "-c", "..." },
        -- },
      })
    end,
  },
}
