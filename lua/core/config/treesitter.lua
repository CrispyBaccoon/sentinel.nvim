local Util = require 'core.utils'

local ensure = { 'markdown', 'markdown_inline', 'vimdoc' }

return {
  setup = function(opts)
    Util.log('treesitter.setup', 'loading treesitter.')
    require 'core.plugins'.load 'treesitter'

    local ok, treesitter = SR_L 'nvim-treesitter'
    if not ok then
      return
    end
    treesitter.setup()

    for _, v in ipairs(ensure) do
      opts.ensure_installed[#opts.ensure_installed + 1] = v
    end
    opts.config.ensure_installed = opts.ensure_installed
    require 'nvim-treesitter.configs'.setup(opts.config)

    keymaps.normal['gm'] = { '<Cmd>Inspect<CR>', 'Show TS highlight groups under cursor' }
  end
}
