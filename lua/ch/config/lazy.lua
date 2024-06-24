local Util = require 'ch.utils'

return {
  setup = function(opts)
    -- set lazy path
    opts.config.root = ch.path.lazy

    -- update global
    ch.modules.ch.lazy.opts = opts

    Util.log('lazy.setup', 'loading lazy.')
    require 'ch.plugins'.load 'lazy.nvim'

    Util.log('lazy.setup', 'loading plugins.')
    ---@diagnostic disable-next-line: redundant-parameter
    require 'lazy'.setup(ch.config.inputs, opts.config)
  end,
}
