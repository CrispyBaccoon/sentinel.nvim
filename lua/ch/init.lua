---@mod ch

if vim.fn.has("nvim-0.10.0") ~= 1 then
    error("chaivim requires Neovim >= 0.10.0")
end

require 'ch.load'

local Util = require 'ch.utils'
local parts = require 'ch.parts'

---@alias ch.types.module.main 'ch'|'config'|'custom'|string

---@class ch.types.module.spec
---@field name ch.types.module.name
---@field event string
---@field opts table|string|nil
---@field reload boolean

---@alias ch.types.module.name 'options'|'highlights'|'base'|'maps'|'plugins'|string
---@alias ch.types.module.table { [ch.types.module.main]: ch.types.module.spec[] }

---@class ch.config
---@field log_level integer
---@field ui ch.config.ui
---@field config_module string
---@field modules ch.types.module.table
---@field inputs LazyPluginSpec[]
---@field plugins string

---@class ch.config.ui
---@field colorscheme string
---@field transparent_background boolean
---@field separator_style 'slant'|'round'|'block'|'arrow'
---@field float_border vim.api.keyset.win_config.border
---@field devicons boolean
---@field theme_config ch.config.ui.theme_config
---@field key_labels table<string, string>

---@class ch.config.ui.theme_config
---@field keyword table<'italic', boolean>
---@field types table<'italic', boolean>
---@field comment table<'italic', boolean>
---@field search table<'reverse', boolean>
---@field inc_search table<'reverse', boolean>

---@class ch.types.global
---@field config ch.config
---@field group_id integer
---@field path ch.types.global.path
---@field loaded boolean
---@field modules InternalModules parsed module configs
---@field lib ch.types.lib

---@class ch.types.lib
---@field icons chIcons
---@field hl ch.types.lib.hl.table
--- ... `ch.lib`

---@class ch.types.global.path
---@field root string
---@field ch string
---@field lazy string
---@field log string

---@alias InternalModules { [ch.types.module.main]: { [ch.types.module.name]: ch.types.module.spec } }

local M = {}

---@type ch.types.global
---@diagnostic disable: missing-fields
_G.ch = _G.ch or {}

---@type ch.config
_G.ch.config = require 'ch.config'.setup(_G.ch.config or {})

local root_path = vim.fn.stdpath("data") .. "/ch"
_G.ch.path = {
  root = root_path,
  log = ('%s/ch_log.txt'):format(vim.fn.stdpath("data")),
}
_G.ch.path.ch = _G.ch.path.root .. "/chai"

_G.ch.modules = _G.ch.modules or {}

---@param ... any
function M.setup(...)
  local args = { ... }
  if #args == 0 then
    Util.log('ch.setup', 'not enough arguments provided', 'error')
    return
  end
  local config = args[1]
  local modules = args[2] or false
  if type(config) == 'string' then
    local status, opts = SR(config)
    if not status or type(opts) ~= 'table' then
      Util.log('ch.setup', 'config module ' .. config .. ' was not found', 'error')
      return
    end
    return M.setup(opts, modules)
  end
  if modules and type(modules) == 'string' then
    local import_mod = modules
    local status, result = SR(import_mod)
    if not status or type(result) ~= 'table' then
      Util.log('ch.setup', 'modules from module ' .. import_mod .. ' were not found', 'error')
      return
    end
    modules = result
  end
  CONFIG_MODULE = config.config_module or 'custom'

  config.config_module = CONFIG_MODULE
  config.modules = modules or config.modules

  require 'ch.config'.setup(config)

  -- preload keymaps module
  parts.preload {}

  M.load()
end

--- load config
function M.load()
  if ch.loaded then
    M.reload()
    return
  end

  Util.log('ch.startup', 'loading config')

  if vim.loader and vim.fn.has "nvim-0.9.1" == 1 then vim.loader.enable() end
  ch.group_id = vim.api.nvim_create_augroup('ch:' .. CONFIG_MODULE, {})
  require 'ch.load.autocmds'.setup {
    group_id = ch.group_id,
  }

  parts.load_modules {}

  parts.colorscheme {}

  parts.load_transparency {}

  parts.platform {}

  ch.loaded = true
end

function M.reload()
  Util.log('ch.reload', 'reloading config')

  vim.api.nvim_del_augroup_by_id(ch.group_id)
  ch.group_id = vim.api.nvim_create_augroup("config:" .. CONFIG_MODULE, {})
  require 'ch.load.autocmds'.setup {
    group_id = ch.group_id,
  }

  parts.load_modules {}

  parts.colorscheme {}

  parts.load_transparency {}

  parts.platform {}

  vim.api.nvim_exec_autocmds('ColorScheme', {})
end

return M
