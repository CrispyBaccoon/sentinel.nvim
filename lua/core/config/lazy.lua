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
    local inputs = core.config.inputs
    local ok
    if type(inputs) == 'string' then
      ok, inputs = pcall(require, inputs)
      if not ok then return end
    end
    core.config.inputs = inputs
    require 'lazy'.setup(core.config.inputs, opts.config)
  end,
}
