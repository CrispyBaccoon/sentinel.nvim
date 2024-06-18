local Util = require 'core.utils'

return {
  boot = function(name)
    local spec = vim.iter(core._inputs):find(function(v)
      return v.name == name
    end)
    if not spec then
      Util.log('core.bootstrap', ('could not find input \'%s\''):format(name))
      return
    end
    Util.boot(spec)
  end,
}
