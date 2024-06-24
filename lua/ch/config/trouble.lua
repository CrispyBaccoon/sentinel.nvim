local Util = require 'ch.utils'

return {
  setup = function(opts)
    Util.log('trouble.setup', 'loading trouble.')
    require('ch.plugins').load 'trouble'

    local ok, trouble = SR_L 'trouble'
    if not ok then
      return
    end

    opts.config.icons = ch.config.ui.devicons
    trouble.setup(opts.config)

    ch.lib.hl.apply {
      TroubleTextWarning = { link = '@text' },
      TroubleLocation = { link = 'NonText' },
    }
  end,
}
