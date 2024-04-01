local Util = require 'core.utils'

return {
  apply_hl = function()
    local highlight = core.lib.options:get('indent', 'config', 'indent', 'highlight')
    for _, hi_name in ipairs(highlight) do
      local hi = vim.api.nvim_get_hl(0, { name = hi_name })
      if vim.tbl_isempty(hi) then
        vim.api.nvim_set_hl(0, hi_name, { link = "NonText", default = true })
      end
    end
  end,
  setup = function(opts)
    Util.log('indent.setup', 'loading indent.')
    require('core.bootstrap').boot 'indent'

    local ok, ibl = SR_L 'ibl'
    if not ok then
      return
    end
    require 'core.config.indent'.apply_hl()

    core.lib.autocmd.create {
      event = 'ColorScheme', priority = GC.priority.handle.colorscheme.plugin,
      fn = function(_)
        require 'core.config.indent'.apply_hl()
      end,
    }
    ibl.setup(opts.config)
  end,
}
