return {
  setup = function(opts)
    require('ch.plugin.hl').setup()

    if opts.use_overrides then
      ch.lib.autocmd.create {
        event = 'ColorScheme',
        priority = GC.priority.handle.colorscheme.theme,
        desc = 'load ui theme',
        fn = function(_)
          local ok, module = SR_L 'ch.ui.theme'
          if not ok then
            return
          end
          module.apply()
        end,
      }
    end
  end,
}
