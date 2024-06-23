local Util = require 'core.utils'
local Plugins = require 'core.plugins'

local parts = {}

function parts.load_modules(_)
  parts.load_config {}

  vim.iter(pairs(core.modules)):each(function(main_mod, modules)
    vim.iter(pairs(modules)):each(function(_, spec)
      core.lib.autocmd.create {
        event = 'custom', type = 'lazycore', priority = spec.priority or nil,
        desc = ('lazycore:%s:%s'):format(main_mod, spec.name),
        fn = function()
          parts.lazy_load(main_mod, spec.name)
        end
      }
    end)
  end)

  require 'core.load.handle'.start 'lazycore'
end

function parts.load_config(_)
  if not core.config.modules['core'] then
    Util.log('core.parts', 'core modules are not defined.', 'error')
    return
  end

  vim.iter(pairs(core.config.modules)):each(function(main_mod, modules)
    Util.log('core.parts', 'loading ' .. main_mod .. ' modules.')
    core.modules[main_mod] = core.modules[main_mod] or {}

    vim.iter(pairs(modules)):each(function(_, spec)
      if spec.opts and type(spec.opts) == 'string' then
        spec.opts = require(spec.opts)
      end
      local name = spec.name or spec[1]
      spec = require 'core.modules'.setup(main_mod, name, spec)

      core.modules[main_mod][name] = spec
    end)

    core.modules[main_mod] = vim.tbl_deep_extend("keep", core.modules[main_mod],
      require 'core.modules'.get_defaults(main_mod))
  end)

  -- update options table
  core.lib.options.__value = core.modules.core
end

---@param main string
---@param name string
function parts.lazy_load(main, name)
  ---@type core.types.module.name
  local module = main .. '.' .. name
  if main == 'core' then
    module = main .. '.config.' .. name
  end

  local spec = core.modules[main][name]

  parts.load(module, spec)
  spec.loaded = true

  if spec.reload then
    require 'core.load.autocmds'.create_reload(module, spec)
  end
end

---@param module string
---@param spec core.types.module.spec
function parts.load(module, spec)
  if spec.enabled == false then
    Util.log('core.parts', 'skipping loading module: ' .. module)
    return
  end
  if spec.loaded and spec.reload == false then
    Util.log('core.parts', 'skipping reloading module: ' .. module)
    return
  end

  ---@param source string
  ---@param opts table
  local callback = function(source, opts)
    local status, result = pcall(require, source)
    if not status then
      Util.log('core.parts', "failed to load " .. source .. "\n\t" .. result, 'error')
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
      group = core.group_id,
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
  if core.config.ui.base46 ~= nil and core.config.ui.colorscheme == 'base46' then
    require('core.plugins').load 'base46'
  end
  local ok, result = pcall(vim.cmd.colorscheme, core.config.ui.colorscheme)
  if not ok then
    Util.log('core.parts', "couldn't load colorscheme\n\t"..result, 'error')
  end

  vim.api.nvim_create_autocmd({ 'UIEnter' }, {
    group = core.group_id,
    once = true,
    callback = function()
      vim.api.nvim_exec_autocmds('ColorScheme', {})
    end
  })
end

function parts.load_transparency(_)
  require 'core.plugin.transparency'.setup()
end

function parts.load_inputs(_)
  core.path.lazy = vim.fs.joinpath(core.path.root, 'lazy')

  local inputs = core.config.inputs
  if type(inputs) == 'string' then
    local result, _inputs = pcall(require, inputs)
    if not result then
      Util.log('parts.load_inputs', ('could not load inputs [%s]:\n\t%s'):format(_inputs, result), 'error')
      return
    end
    inputs = _inputs
  end
  core.config.inputs = inputs
  ---@class core.types.global
  ---@field _inputs LazyPluginSpec[]
  core._inputs = Plugins.parse_inputs(core.config.inputs)
end

function parts.preload(_)
  parts.load_lib {}

  parts.load_inputs {}
  require 'core.plugins'.load 'lazy.nvim'
  require 'core.plugins'.load 'keymaps'
  local ok, result = SR_L 'keymaps'
  if ok then
    result.setup()
  end
  require 'core.plugins'.load 'yosu'
  require 'core.plugins'.load 'plenary'
  require 'core.plugins'.load 'telescope'
  require 'core.plugins'.load 'evergarden'

  if not keymaps then
    Util.log('core.parts', 'global keymaps is not defined.', 'error')
    return
  end
end

function parts.load_lib(_)
  require 'core.lib'.setup()
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
