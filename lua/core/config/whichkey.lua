local Util = require 'core.utils'

return {
  setup = function(opts)
    Util.log('whichkey.setup', 'loading whichkey.')
    require('core.plugins').load 'whichkey'

    local ok, which = SR_L 'which-key'
    if not ok then
      return
    end

    if not opts.config.key_labels then
      opts.config.key_labels =
        core.config.ui.key_labels
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
