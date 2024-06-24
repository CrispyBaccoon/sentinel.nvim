local Util = require 'ch.utils'

return {
  setup = function(opts)
    Util.log('incline.setup', 'loading incline.')
    require('ch.plugins').load 'incline'

    local ok, incline = SR_L 'incline'
    if not ok then
      return
    end

    incline.setup(opts.config)
  end,
}
