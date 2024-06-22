local Util = require 'core.utils'

local ensure = { 'markdown', 'markdown_inline', 'vimdoc' }

return {
  setup = function(opts)
    Util.log('treesitter.setup', 'loading treesitter.')
    require('core.plugins').load 'treesitter'

    local ok, treesitter = SR_L 'nvim-treesitter'
    if not ok then
      return
    end
    treesitter.setup()

    if
      type(opts.ensure_installed) == 'string'
      and opts.ensure_installed ~= 'all'
    then
      opts.ensure_installed = { opts.ensure_installed }
    end
    if type(opts.ensure_installed) == 'table' then
      for _, v in ipairs(ensure) do
        ---@diagnostic disable-next-line: assign-type-mismatch
        opts.ensure_installed[#opts.ensure_installed + 1] = v
      end
    end
    opts.config.ensure_installed = opts.ensure_installed
    require('nvim-treesitter.configs').setup(opts.config)

    keymaps.normal['gm'] =
      { vim.show_pos, 'Show TS highlight groups under cursor' }
  end,
}
