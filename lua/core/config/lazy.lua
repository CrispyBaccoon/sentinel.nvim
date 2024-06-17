local Util = require 'core.utils'

return {
  setup = function(opts)
    -- set lazy path
    opts.config.root = core.path.lazy

    -- update global
    core.modules.core.lazy.opts = opts

    Util.log('lazy.setup', 'loading lazy.')
    require 'core.bootstrap'.boot 'lazyplug'

    Util.log('lazy.setup', 'loading plugins.')
    ---@diagnostic disable-next-line: redundant-parameter
    require 'lazy'.setup(core.config.inputs, opts.config)
  end,
}
