local Util = require 'ch.utils'

local opts_table = {
  bottom = {
    notification = {
      view = {
        stack_upwards = true,
      },
      window = {
        align = 'bottom',
      },
    },
  },
  top = {
    notification = {
      view = {
        stack_upwards = false,
      },
      window = {
        align = 'top',
      },
    },
  },
}

return {
  setup = function(opts)
    Util.log('fidget.setup', 'loading fidget.')
    require('ch.plugins').load 'fidget'

    local ok, fidget = SR_L 'fidget'
    if not ok then
      return
    end
    local additional_opts = opts_table[opts.ui.position]
    opts.config = vim.tbl_deep_extend('force', opts.config, additional_opts)

    fidget.setup(opts.config)
  end,
}
