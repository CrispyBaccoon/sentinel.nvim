local default_modules = {
  ch = {
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
    local ok, import = SR(string.format('%s.%s', main == 'ch' and 'ch.config' or main, module))
    if ok and type(import) == 'table' and import.module then
      return import.module
    end
    ---@diagnostic disable-next-line: redefined-local
    local ok, import = SR(string.format('ch.modules.%s.%s', main, module))
    if ok and import then
      return import
    end
    return {}
  end,
  get_defaults = function(main)
    if not default_modules[main] then
      return {}
    end

    local modules = {}
    vim.iter(pairs(default_modules[main])):each(function(event, list)
      vim.iter(ipairs(list)):each(function(i, module)
        modules[module] = require 'ch.modules'.setup(main, module, {
          priority = i,
          event = event_map[event] or nil,
        })
      end)
    end)
    return modules
  end,
  setup = function(main, module, spec)
    local ok, default = SR_L 'ch.modules.default'
    if not ok then
      return
    end
    local import = require 'ch.modules'.get_module(main, module)
    import = vim.tbl_deep_extend('force', default, import)

    ---@type ch.types.module.spec
    local _spec = {
      name = module,
      reload = nil,
      event = nil,
      opts = nil,
      loaded = false,
    }

    _spec = vim.tbl_deep_extend('force', _spec, spec)
    _spec = vim.tbl_deep_extend('force', import.default, _spec)

    if ch.loaded and ch.modules[main] and ch.modules[main][module] then
      _spec.loaded = ch.modules[main][module].loaded
    end

    _spec = vim.tbl_deep_extend('force', _spec, import.overwrite)

    return _spec
  end
}
