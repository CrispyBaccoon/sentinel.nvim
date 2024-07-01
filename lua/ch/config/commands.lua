return {
  module = {
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
  },
  setup = function(opts)
    vim.iter(pairs(opts.commands)):each(function(name, props)
      require 'ch.plugin.command'.create {
        name = name,
        fn = type(props) == 'table' and props.fn or props,
        opts = type(props) == 'table' and props.opts or nil,
      }
    end)
  end,
}
