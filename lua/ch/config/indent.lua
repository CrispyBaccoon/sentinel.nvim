return {
  module = {
    default = {
      event = 'BufAdd',
      opts = {
        config = {
          indent = {
            highlight = {
              '@ibl.indent.char.1',
              '@ibl.indent.char.2',
              '@ibl.indent.char.3',
              '@ibl.indent.char.4',
              '@ibl.indent.char.5',
              '@ibl.indent.char.6',
              '@ibl.indent.char.7',
              '@ibl.indent.char.8',
              '@ibl.indent.char.9',
              '@ibl.indent.char.10',
              '@ibl.indent.char.11',
              '@ibl.indent.char.12',
            },
          },
          scope = {
            enabled = false,
          },
        },
      },
    },
  },
  apply_hl = function()
    local highlight = ch.lib.options:get('indent', 'config', 'indent', 'highlight')
    for _, hi_name in ipairs(highlight) do
      local hi = vim.api.nvim_get_hl(0, { name = hi_name })
      if vim.tbl_isempty(hi) then
        vim.api.nvim_set_hl(0, hi_name, { link = "NonText", default = true })
      end
    end
  end,
  setup = function(opts)
    ch.log('indent.setup', 'loading indent.')
    require('ch.plugins').load 'indent'

    local ok, ibl = SR_L 'ibl'
    if not ok then
      return
    end
    require 'ch.config.indent'.apply_hl()

    ch.lib.autocmd.create {
      event = 'ColorScheme', priority = GC.priority.handle.colorscheme.plugin,
      desc = 'apply indent hls',
      fn = function(_)
        require 'ch.config.indent'.apply_hl()
      end,
    }
    ibl.setup(opts.config)
  end,
}
