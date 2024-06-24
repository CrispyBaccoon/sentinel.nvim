---@mod core

if vim.fn.has("nvim-0.10.0") ~= 1 then
    error("chaivim requires Neovim >= 0.10.0")
end

require 'core.load'

local Util = require 'core.utils'
local parts = require 'core.parts'

---@alias core.types.module.main 'core'|'config'|'custom'|string

---@class core.types.module.spec
---@field name core.types.module.name
---@field event string
---@field opts table|string|nil
---@field reload boolean

---@alias core.types.module.name 'options'|'highlights'|'base'|'maps'|'plugins'|string
---@alias core.types.module.table { [core.types.module.main]: core.types.module.spec[] }

---@class core.config
---@field log_level integer
---@field ui core.config.ui
---@field config_module string
---@field modules core.types.module.table
---@field inputs LazyPluginSpec[]
---@field plugins string

---@class core.config.ui
---@field colorscheme string
---@field transparent_background boolean
---@field separator_style 'slant'|'round'|'block'|'arrow'
---@field float_border vim.api.keyset.win_config.border
---@field devicons boolean
---@field theme_config core.config.ui.theme_config
---@field key_labels table<string, string>

---@class core.config.ui.theme_config
---@field keyword table<'italic', boolean>
---@field types table<'italic', boolean>
---@field comment table<'italic', boolean>
---@field search table<'reverse', boolean>
---@field inc_search table<'reverse', boolean>

---@class core.types.global
---@field config core.config
---@field group_id integer
---@field path core.types.global.path
---@field loaded boolean
---@field modules InternalModules parsed module configs
---@field lib core.types.lib

---@class core.types.lib
---@field icons CoreIcons
---@field hl core.types.lib.hl.table
--- ... `core.lib`

---@class core.types.global.path
---@field root string
---@field core string
---@field lazy string
---@field log string

---@alias InternalModules { [core.types.module.main]: { [core.types.module.name]: core.types.module.spec } }

local M = {}

---@type core.types.global
---@diagnostic disable: missing-fields
_G.core = _G.core or {}

---@type core.config
_G.core.config = require 'core.config'.setup(_G.core.config or {})

local root_path = vim.fn.stdpath("data") .. "/core"
_G.core.path = {
  root = root_path,
  log = ('%s/core_log.txt'):format(vim.fn.stdpath("data")),
}
_G.core.path.core = _G.core.path.root .. "/chai"

_G.core.modules = _G.core.modules or {}

---@param ... any
function M.setup(...)
  local args = { ... }
  if #args == 0 then
    Util.log('core.setup', 'not enough arguments provided', 'error')
    return
  end
  local config = args[1]
  local modules = args[2] or false
  if type(config) == 'string' then
    local status, opts = SR(config)
    if not status or type(opts) ~= 'table' then
      Util.log('core.setup', 'config module ' .. config .. ' was not found', 'error')
      return
    end
    return M.setup(opts, modules)
  end
  if modules and type(modules) == 'string' then
    local import_mod = modules
    local status, result = SR(import_mod)
    if not status or type(result) ~= 'table' then
      Util.log('core.setup', 'modules from module ' .. import_mod .. ' were not found', 'error')
      return
    end
    modules = result
  end
  CONFIG_MODULE = config.config_module or 'custom'

  config.config_module = CONFIG_MODULE
  config.modules = modules or config.modules

  require 'core.config'.setup(config)

  -- preload keymaps module
  parts.preload {}

  M.load()
end

--- load config
function M.load()
  if core.loaded then
    M.reload()
    return
  end

  Util.log('core.startup', 'loading config')

  if vim.loader and vim.fn.has "nvim-0.9.1" == 1 then vim.loader.enable() end
  core.group_id = vim.api.nvim_create_augroup('core:' .. CONFIG_MODULE, {})
  require 'core.load.autocmds'.setup {
    group_id = core.group_id,
  }

  parts.load_modules {}

  parts.colorscheme {}

  parts.load_transparency {}

  parts.platform {}

  core.loaded = true
end

function M.reload()
  Util.log('core.reload', 'reloading config')

  vim.api.nvim_del_augroup_by_id(core.group_id)
  core.group_id = vim.api.nvim_create_augroup("config:" .. CONFIG_MODULE, {})
  require 'core.load.autocmds'.setup {
    group_id = core.group_id,
  }

  parts.load_modules {}

  parts.colorscheme {}

  parts.load_transparency {}

  parts.platform {}

  vim.api.nvim_exec_autocmds('ColorScheme', {})
end

return M
