local utils = R 'core.ui.statusline.utils'

local M = {}

---@alias NvMode 'n'|'no'|'nov'|'noV'|'noCTRL-V'|'niI'|'niR'|'niV'|'nt'|'ntT'|'v'|'vs'|'V'|'Vs'|'␖'|'i'|'ic'|'ix'|'t'|'R'|'Rc'|'Rx'|'Rv'|'Rvc'|'Rvx'|'s'|'S'|'␓'|'c'|'cv'|'ce'|'r'|'rm'|'r?'|'x'|'!'

---@type NvMode
_G.nvmode = 'n'

local separator_style = core.config.ui.separator_style

---@type { left: string, right: string }
---@diagnostic disable-next-line: assign-type-mismatch
local separators = core.lib.icons.separator[separator_style]
if not separators then
  separators = { left = '', right = '' }
end
local sep_r = separators.right
local sep_l = separators.left
local sep_mid = '%='

local config_modules = {
  a = { 'mode' },
  b = { 'fileinfo' },
  c = { 'git_branch', 'lsp_diagnostics' },
  x = { 'git_status', 'lsp_status' },
  y = { 'cwd' },
  z = { 'textinfo', 'cursor_position' },
}

local function parse_c(c, ...)
  if type(c) == 'string' then
    local ok, mod = SR(('core.ui.statusline.modules.%s'):format(c))
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
    x = parse_components(config_modules.x),
    y = parse_components(config_modules.y),
    z = parse_components(config_modules.z),
  }

  local m = utils.getmode()

  modules[#modules + 1] = '%#St_normal#'
      .. m.hl .. ' '
      .. table.concat(_modules.a)
      .. m.sep_hl
      .. sep_r
  modules[#modules + 1] = '%#St_section_b#'
      .. table.concat(_modules.b)
      .. '%#St_section_b_sep#'
      .. sep_r
  modules[#modules + 1] = '%#St_section_c#' .. table.concat(_modules.c)
  modules[#modules + 1] = '%#St_normal#' .. sep_mid
  modules[#modules + 1] = '%#St_section_x#' .. table.concat(_modules.x)
  modules[#modules + 1] = '%#St_section_y_sep#'
      .. sep_l
      .. '%#St_section_y#'
      .. table.concat(_modules.y)
  modules[#modules + 1] = m.sep_hl .. sep_l .. m.hl .. table.concat(_modules.z)

  -- return table.concat(_modules)

  return modules
end

M.run = function()
  _G.nvmode = vim.api.nvim_get_mode().mode
  local modules = M.parse()
  return table.concat(modules)
end

return M
