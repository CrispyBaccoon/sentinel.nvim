return {
  setup = function(opts)
    ch.log('null.setup', 'loading null-ls.')
    require('ch.plugins').load 'null'

    local ok, null_ls = SR_L 'null-ls'
    if not ok then
      return
    end

    if opts.sources and type(opts.sources) == 'function' then
      opts.config.sources =
        vim.tbl_deep_extend('force', opts.config.sources, opts.sources(null_ls))
    end

    null_ls.setup(opts.config)

    Keymap.group {
      group = 'null',
      {
        {
          'normal',
          opts.mappings.format,
          function()
            vim.lsp.buf.format { async = true, name = 'null-ls' }
          end,
          'format with null-ls',
        },
      }
    }
  end,
}
