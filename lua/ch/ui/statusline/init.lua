local utils = R 'ch.ui.statusline.utils'

local M = {}

---@alias NvMode 'n'|'no'|'nov'|'noV'|'noCTRL-V'|'niI'|'niR'|'niV'|'nt'|'ntT'|'v'|'vs'|'V'|'Vs'|'␖'|'i'|'ic'|'ix'|'t'|'R'|'Rc'|'Rx'|'Rv'|'Rvc'|'Rvx'|'s'|'S'|'␓'|'c'|'cv'|'ce'|'r'|'rm'|'r?'|'x'|'!'

---@type NvMode
_G.nvmode = 'n'

local separator_style = ch.config.ui.separator_style

---@type { left: string, right: string }
---@diagnostic disable-next-line: assign-type-mismatch
local separators = ch.lib.icons.separator[separator_style]
if not separators then
  separators = { left = '', right = '' }
end
local sep = {
  r = separators.right,
  l = separators.left,
  mid = '%=',
}

local config_modules = {
  a = { 'mode' },
  b = { 'fileinfo' },
  c = { 'git_branch', 'lsp_diagnostics' },
  m = { { 'macro', function(key) return ('recording %s ...'):format(key) end } },
  x = { 'git_status', 'lsp_status' },
  y = { 'cwd' },
  z = { 'textinfo', 'cursor_position' },
}

local function parse_c(c, ...)
  if type(c) == 'string' then
    local ok, mod = pcall(require, ('ch.ui.statusline.modules.%s'):format(c))
    if ok then
      ---@diagnostic disable-next-line: redefined-local
      local ok, str = pcall(mod, ...)
      if ok then
        return str
      end
    end
  else
    local ok, str = pcall(c, ...)
    if ok then
      return str
    end
  end
end

local function parse_components(components)
  return vim.iter(components):map(function(c)
    if type(c) == 'table' then
      return parse_c(unpack(c))
    end
    return parse_c(c)
  end):totable()
end

M.parse = function()
  local modules = {}

  ---@type { ['a'|'b'|'c'|'x'|'y'|'z']: string[] }
  local _modules = {
    a = parse_components(config_modules.a),
    b = parse_components(config_modules.b),
    c = parse_components(config_modules.c),
    m = parse_components(config_modules.m),
    x = parse_components(config_modules.x),
    y = parse_components(config_modules.y),
    z = parse_components(config_modules.z),
  }

  local m = utils.getmode()

  modules[#modules + 1] = '%#St_normal#'
      .. m.hl('a') .. ' '
      .. table.concat(_modules.a)
      .. m.sep_hl('a')
      .. sep.r
  modules[#modules + 1] = m.hl('b')
      .. table.concat(_modules.b)
      .. m.sep_hl('b')
      .. sep.r
  modules[#modules + 1] = m.hl('c') .. table.concat(_modules.c)
  modules[#modules + 1] = '%#St_normal#' .. sep.mid
  modules[#modules + 1] = m.hl('m') .. table.concat(_modules.m)
  modules[#modules + 1] = '%#St_normal#' .. sep.mid
  modules[#modules + 1] = m.hl('x') .. table.concat(_modules.x)
  modules[#modules + 1] = m.sep_hl('y')
      .. sep.l
      .. m.hl('y')
      .. table.concat(_modules.y)
  modules[#modules + 1] = m.sep_hl('z') .. sep.l .. m.hl('z') .. table.concat(_modules.z)

  -- return table.concat(_modules)

  return modules
end

M.run = function()
  _G.nvmode = vim.api.nvim_get_mode().mode
  local modules = M.parse()
  return table.concat(modules)
end

return M
