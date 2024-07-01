return {
  module = {
    default = {
      opts = {
        config = {
          ui = {
            -- a number <1 is a percentage., >1 is a fixed size
            size = { width = 90, height = 0.8 },
            wrap = true, -- wrap the lines in the ui
            -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
            border = 'none',
            -- The backdrop opacity. 0 is fully opaque, 100 is fully transparent.
            backdrop = 100,
            icons = {
              cmd = "! ",
              config = ch.lib.icons.syntax.constructor,
              event = ch.lib.icons.syntax.event,
              ft = ch.lib.icons.syntax.file,
              init = ch.lib.icons.syntax.constructor,
              import = ch.lib.icons.syntax.reference,
              keys = ch.lib.icons.syntax.snippet,
              lazy = ch.lib.icons.syntax.fn,
              loaded = ch.lib.icons.info.loaded,
              not_loaded = ch.lib.icons.info.not_loaded,
              plugin = ch.lib.icons.syntax.package,
              runtime = ch.lib.icons.syntax.null,
              source = ch.lib.icons.syntax.module,
              start = ch.lib.icons.debug.start,
              task = ch.lib.icons.ui.item_prefix,
              list = {
                '-',
                '*',
                '*',
                '-',
              },
            },
          },
        },
      },
    },
    overwrite = {
      reload = false,
      opts = {
        config = {
          root = nil, -- directory where plugins will be installed
          -- required for ch bootstrap
          performance = {
            reset_packpath = false,
            rtp = {
              reset = false,
            },
          },
        },
      },
    },
  },
  setup = function(opts)
    -- set lazy path
    opts.config.root = ch.path.lazy

    -- update global
    ch.modules.ch.lazy.opts = opts

    ch.log('lazy.setup', 'loading lazy.')
    require 'ch.plugins'.load 'lazy.nvim'

    ch.log('lazy.setup', 'loading plugins.')
    ---@diagnostic disable-next-line: redundant-parameter
    require 'lazy'.setup(ch.config.inputs, opts.config)
  end,
}
