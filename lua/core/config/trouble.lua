local Util = require 'core.utils'

return {
  setup = function(opts)
    Util.log('trouble.setup', 'loading trouble.')
    require('core.plugins').load 'trouble'

    local ok, trouble = SR_L 'trouble'
    if not ok then
      return
    end

    opts.config.icons = core.config.ui.devicons
    trouble.setup(opts.config)

    core.lib.hl.apply {
      TroubleTextWarning = { link = '@text' },
      TroubleLocation = { link = 'NonText' },
    }
  end,
}
