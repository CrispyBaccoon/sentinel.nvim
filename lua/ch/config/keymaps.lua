local Util = require 'ch.utils'

return {
  setup = function(opts)
    local _leader = opts.leader
    if opts.leader == 'space' or opts.leader == 'SPC' then
      _leader = ' '
    end

    local _localleader = _leader .. opts.localleader

    Util.log('keymaps.setup', string.format('set leader to "%s"', _leader))
    Util.log('keymaps.setup', string.format('set localleader to "%s"', _localleader))
    vim.g.mapleader = _leader
    vim.g.maplocalleader = _localleader

    -- key labels
    local key_labels = ch.config.ui.key_labels
    local repl_keys = {}

    if not opts.special_keys then
      opts.special_keys = {}
      vim.iter(pairs(key_labels)):each(function(m, k)
        opts.special_keys[k] = m
        repl_keys[string.lower(m)] = k
      end)
    else
      vim.iter(pairs(opts.special_keys)):each(function(m, k)
        repl_keys[string.lower(k)] = m
      end)
    end
    require 'keymaps'.setup {
      default_opts = opts.defaults,
      special_keys = opts.special_keys
    }
    keymaps_config.repl_keys = repl_keys
    keymaps_config.repl_keys['<leader>'] = opts.leader
    keymaps_config.repl_keys['<localleader>'] = opts.leader .. '+' .. opts.localleader
    keymaps_config.repl_keys['<[c]%-([%w])>'] = 'CTRL+%1'
    keymaps_config.repl_keys['<[m]%-([%w])>'] = 'META+%1'
    keymaps_config.repl_keys['<[a]%-([%w])>'] = 'ALT+%1'
    keymaps_config.repl_keys['<[s]%-([%w])>'] = 'SHIFT+%1'

    -- load keymaps plugin
    vim.iter(pairs(opts.mappings)):each(function(group, mappings)
      Keymap.group { group = group, mappings }
    end)

    if ch.lib.options:get('ui', 'terminal', 'enabled') then
      require('ch.ui.term').setup_keymaps(
        ch.lib.options:get('ui', 'terminal')
      )
    end
  end,
  cheatsheet = function(props)
    require 'ch.ui.cheatsheet'.open(props)
  end,
}
