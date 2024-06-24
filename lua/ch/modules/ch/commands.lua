return {
  default = {
    opts = {
      commands = {
        cheatsheet = require 'ch.ui.cheatsheet'.open,
        ['ToggleTransparentBG'] = function()
          ---@diagnostic disable
          _G.toggle_transparent_background()
        end,
      },
    },
  },
}
