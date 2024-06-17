return {
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
            config = core.lib.icons.syntax.constructor,
            event = core.lib.icons.syntax.event,
            ft = core.lib.icons.syntax.file,
            init = core.lib.icons.syntax.constructor,
            import = core.lib.icons.syntax.reference,
            keys = core.lib.icons.syntax.snippet,
            lazy = core.lib.icons.syntax.fn,
            loaded = core.lib.icons.info.loaded,
            not_loaded = core.lib.icons.info.not_loaded,
            plugin = core.lib.icons.syntax.package,
            runtime = core.lib.icons.syntax.null,
            source = core.lib.icons.syntax.module,
            start = core.lib.icons.debug.start,
            task = core.lib.icons.ui.item_prefix,
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
        -- required for core bootstrap
        performance = {
          reset_packpath = false,
          rtp = {
            reset = false,
          },
        },
      },
    },
  },
}
