local Util = require 'ch.utils'
local Plugins = require 'ch.plugins'

local parts = {}

function parts.load_modules(_)
  parts.load_config {}

  vim.iter(pairs(ch.modules)):each(function(main_mod, modules)
    vim.iter(pairs(modules)):each(function(_, spec)
      ch.lib.autocmd.create {
        event = 'custom', type = 'lazych', priority = spec.priority or nil,
        desc = ('lazych:%s:%s'):format(main_mod, spec.name),
        fn = function()
          parts.lazy_load(main_mod, spec.name)
        end
      }
    end)
  end)

  require 'ch.load.handle'.start 'lazych'
end

function parts.load_config(_)
  if not ch.config.modules['ch'] then
    Util.log('ch.parts', 'ch modules are not defined.', 'error')
    return
  end

  vim.iter(pairs(ch.config.modules)):each(function(main_mod, modules)
    Util.log('ch.parts', 'loading ' .. main_mod .. ' modules.')
    ch.modules[main_mod] = ch.modules[main_mod] or {}

    vim.iter(pairs(modules)):each(function(_, spec)
      if spec.opts and type(spec.opts) == 'string' then
        spec.opts = require(spec.opts)
      end
      local name = spec.name or spec[1]
      spec = require 'ch.modules'.setup(main_mod, name, spec)

      ch.modules[main_mod][name] = spec
    end)

    ch.modules[main_mod] = vim.tbl_deep_extend("keep", ch.modules[main_mod],
      require 'ch.modules'.get_defaults(main_mod))
  end)

  -- update options table
  ch.lib.options.__value = ch.modules.ch
end

---@param main string
---@param name string
function parts.lazy_load(main, name)
  ---@type ch.types.module.name
  local module = main .. '.' .. name
  if main == 'ch' then
    module = main .. '.config.' .. name
  end

  local spec = ch.modules[main][name]

  parts.load(module, spec)
  spec.loaded = true

  if spec.reload then
    require 'ch.load.autocmds'.create_reload(module, spec)
  end
end

---@param module string
---@param spec ch.types.module.spec
function parts.load(module, spec)
  if spec.enabled == false then
    Util.log('ch.parts', 'skipping loading module: ' .. module)
    return
  end
  if spec.loaded and spec.reload == false then
    Util.log('ch.parts', 'skipping reloading module: ' .. module)
    return
  end

  ---@param source string
  ---@param opts table
  local callback = function(source, opts)
    local status, result = pcall(require, source)
    if not status then
      Util.log('ch.parts', "failed to load " .. source .. "\n\t" .. result, 'error')
      return
    end
    if type(result) == 'table' then
      if result.setup then
        if not type(spec.opts) == 'table' then
          return
        end
        result.setup(opts)
      end
    end
  end

  if spec.event and not spec.loaded then
    vim.api.nvim_create_autocmd({ spec.event }, {
      group = ch.group_id,
      once = true,
      callback = function()
        callback(module, spec.opts)
      end,
    })
  else
    callback(module, spec.opts)
  end
end

function parts.colorscheme(_)
  ---@diagnostic disable-next-line: undefined-field
  if ch.config.ui.base46 ~= nil and ch.config.ui.colorscheme == 'base46' then
    require('ch.plugins').load 'base46'
  end
  local ok, result = pcall(vim.cmd.colorscheme, ch.config.ui.colorscheme)
  if not ok then
    Util.log('ch.parts', "couldn't load colorscheme\n\t"..result, 'error')
  end

  vim.api.nvim_create_autocmd({ 'UIEnter' }, {
    group = ch.group_id,
    once = true,
    callback = function()
      vim.api.nvim_exec_autocmds('ColorScheme', {})
    end
  })
end

function parts.load_transparency(_)
  require 'ch.plugin.transparency'.setup()
end

function parts.load_inputs(_)
  ch.path.lazy = vim.fs.joinpath(ch.path.root, 'lazy')

  local inputs = ch.config.inputs
  if type(inputs) == 'string' then
    local result, _inputs = pcall(require, inputs)
    if not result then
      Util.log('parts.load_inputs', ('could not load inputs [%s]:\n\t%s'):format(_inputs, result), 'error')
      return
    end
    inputs = _inputs
  end
  ch.config.inputs = inputs
  ---@class ch.types.global
  ---@field _inputs LazyPluginSpec[]
  ch._inputs = Plugins.parse_inputs(ch.config.inputs)
end

function parts.preload(_)
  parts.load_lib {}

  parts.load_inputs {}
  require 'ch.plugins'.load 'lazy.nvim'
  require 'ch.plugins'.load 'keymaps'
  local ok, result = SR_L 'keymaps'
  if ok then
    result.setup()
  end
  require 'ch.plugins'.load 'yosu'
  require 'ch.plugins'.load 'plenary'
  require 'ch.plugins'.load 'telescope'
  require 'ch.plugins'.load 'evergarden'

  if not keymaps then
    Util.log('ch.parts', 'global keymaps is not defined.', 'error')
    return
  end
end

function parts.load_lib(_)
  require 'ch.lib'.setup()
end

function parts.platform(_)
  local is_mac = Util.has 'mac'
  local is_win = Util.has 'win32'
  local is_neovide = vim.g.neovide

  if is_mac then
    require(CONFIG_MODULE .. '.macos')
  end
  if is_win then
    require(CONFIG_MODULE .. '.windows')
  end
  if is_neovide then
    require(CONFIG_MODULE .. '.neovide')
  end
end

return parts
