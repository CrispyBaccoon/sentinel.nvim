local Util = require 'core.utils'

return {
  boot = function(name)
    local spec = vim.iter(core._inputs):find(function(v)
      return v.name == name
    end)
    if spec then
      Util.boot(spec)
    end
  end,
}
