local Util = require 'core.utils'

local function load_plugin(name, spec)
  Util.log('mini.setup', string.format('loading mini.%s', name))
  local mod = require('mini.' .. name)
  spec.config = spec.config or function(_, opts) mod.setup(opts) end
  spec.config(mod, spec.opts)
end

return {
  setup = function(opts)
    Util.log('mini.setup', 'loading mini.')
    require 'core.plugins'.load 'mini'

    vim.iter(pairs(opts.plugins)):each(function(name, c)
      load_plugin(name, c)
    end)
  end
}
