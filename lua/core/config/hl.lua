return {
  setup = function(opts)
    require('core.plugin.hl').setup()

    if opts.use_overrides then
      core.lib.autocmd.create {
        event = 'ColorScheme',
        priority = GC.priority.handle.colorscheme.theme,
        desc = 'load ui theme',
        fn = function(_)
          local ok, module = SR_L 'core.ui.theme'
          if not ok then
            return
          end
          module.apply()
        end,
      }
    end
  end,
}
