local Util = require 'core.utils'

local default_modules = {
  core = {
    init = {
      'base', 'options', 'hl', 'ui', 'highlights', 'keymaps',
      'lazy', 'lualine', 'treesitter', 'lsp', 'null',
    },
    buf = { 'luasnip', 'cmp', },
    ui = {
      'telescope', 'mini', 'gitsigns', 'whichkey',
      'dash',
      'commands',
      'trouble', 'todo_comments',
      'incline', 'indent',
    },
  },
}

local event_map = {
  ui = 'UIEnter',
  buf = 'BufAdd',
}

return {
  get_module = function(main, module)
    return SR(string.format('core.modules.%s.%s', main, module))
  end,
  get_defaults = function(main)
    if not default_modules[main] then
      return {}
    end

    local modules = {}
    vim.iter(pairs(default_modules[main])):each(function(event, list)
      vim.iter(ipairs(list)):each(function(i, module)
        modules[module] = require 'core.modules'.setup(main, module, {
          priority = i,
          event = event_map[event] or nil,
        })
      end)
    end)
    return modules
  end,
  setup = function(main, module, spec)
    local ok, default = SR_L 'core.modules.default'
    if not ok then
      return
    end
    ---@diagnostic disable-next-line redefined-local
    local ok, import = require 'core.modules'.get_module(main, module)
    if not ok then
      import = {}
    end
    import = vim.tbl_deep_extend('force', default, import)

    ---@type core.types.module.spec
    local _spec = {
      name = module,
      reload = nil,
      event = nil,
      opts = nil,
      loaded = false,
    }

    _spec = vim.tbl_deep_extend('force', _spec, spec)
    _spec = vim.tbl_deep_extend('force', import.default, _spec)

    if core.loaded and core.modules[main] and core.modules[main][module] then
      _spec.loaded = core.modules[main][module].loaded
    end

    _spec = vim.tbl_deep_extend('force', _spec, import.overwrite)

    return _spec
  end
}
