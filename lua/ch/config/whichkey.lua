local Util = require 'ch.utils'

return {
  setup = function(opts)
    Util.log('whichkey.setup', 'loading whichkey.')
    require('ch.plugins').load 'whichkey'

    local ok, which = SR_L 'which-key'
    if not ok then
      return
    end

    if not opts.config.key_labels then
      opts.config.key_labels =
        ch.config.ui.key_labels
    end
    which.setup(opts.config)

    which.register {
      ['.'] = { name = 'toggle' },
      [','] = { name = 'edit' },
      ['<leader>'] = {
        f = { name = 'find' },
        s = { name = 'show' },
        g = { name = 'go' },
      },
    }
  end,
}
