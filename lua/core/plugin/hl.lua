---@diagnostic disable duplicate-doc-alias

---@alias core.types.hl.color integer|'none'

---@alias core.types.hl.highlight { fg: core.types.hl.color, bg: core.types.hl.color  }

---@class core.types.lib.hl.table
---@field ui core.types.hl.table.ui
---@field diagnostic table<core.types.lib.hl.table.diagnostic.enum, integer>
---@field diff table<core.types.lib.hl.table.diff.enum, integer>
---@field syntax table<core.types.lib.hl.table.syntax.enum, integer>

---@class core.types.lib.hl.table.ui
---@field fg integer normal fg
---@field bg integer normal bg
---@field bg_dark integer bg for items that require less visual priority
---@field bg_accent integer bg for items that require visual priority; signcolumn
---@field bg1 integer extra bg color
---@field bg2 integer extra bg color
---@field bg3 integer extra bg color
---@field grey1 integer extra fg color
---@field grey2 integer extra fg color
---@field grey3 integer extra fg color
---@field accent integer accent color for titles and tabs
---@field current integer bg color for current item
---@field focus integer focused item
---@field match integer color for matching text
---@field border integer fg color for borders and window separators
---@field pmenu_bg integer bg color for pmenu
---@field statusline_bg integer bg color for statusline
---@field folder_bg integer bg color for folders
---@field bg_alt integer alternate bg color
---@field red integer red
---@field rose integer dark pink
---@field pink integer pink
---@field green integer green
---@field vibrant integer dark green
---@field nord integer blue
---@field blue integer dark blue
---@field orange integer orange
---@field yellow integer yellow
---@field peach integer dark yellow
---@field purple integer purple
---@field mauve integer dark_purple
---@field cyan integer cyan
---@field teal integer dark cyan
---@alias core.types.lib.hl.table.diagnostic.enum 'ok'|'warn'|'error'|'info'|'hint'
---@alias core.types.lib.hl.table.diff.enum 'add'|'change'|'delete'
---@alias core.types.lib.hl.table.syntax.enum 'special'|'title'|'identifier'|'type'|'structure'|'text'|'method'|'fn'|'constructor'|'field'|'variable'|'class'|'interface'|'module'|'property'|'unit'|'value'|'enum'|'keyword'|'snippet'|'color'|'file'|'reference'|'folder'|'enummember'|'constant'|'struct'|'event'|'operator'|'typeparameter'|'namespace'|'table'|'object'|'tag'|'array'|'boolean'|'number'|'null'|'string'|'package'

---@alias CoreHlName core.types.lib.hl.table.ui.enum|core.types.lib.hl.table.diagnostic.enum|core.types.lib.hl.table.diff.enum|core.types.lib.hl.table.syntax.enum

---@param props { [1]: CoreHlName, [2]: string, bg?: boolean }[]
---@return { [string]: core.types.hl.highlight }
local function create_hls(props)
  local hls = {}
  for _, v in ipairs(props) do
    local name = v[1]

    function get(name)
      local copy = vim.api.nvim_get_hl(0, { name = name })
      if copy.link then
        return get(copy.link)
      end
      if v.bg then
        local bg = copy.bg ~= nil and copy.bg or copy.fg
        return bg or 'none'
      end
      return copy.fg or 'none'
    end
    hls[name] = get(v[2])
  end
  return hls
end

return {
  setup = function()
    require 'core.plugin.hl'.load()

    require 'core.load.handle'.create {
      event = 'ColorScheme', priority = GC.priority.handle.colorscheme.hl,
      desc = 'load hl plugin',
      fn = function(_)
        require 'core.plugin.hl'.load()
      end,
    }
  end,
  ---@return core.types.lib.hl.table
  create = function()
    return {
      ui = create_hls {
        { 'fg',        'Normal' },
        { 'bg',        'Normal', bg = true },
        { 'bg_accent', 'SignColumn', bg = true },
        { 'accent',    'TablineSel', bg = true },
        { 'current',   'CursorLine', bg = true },
        { 'focus',     'IncSearch', bg = true },
        { 'match',     'Search' },
        { 'border',    'WinSeparator' },
        { 'comment',   'Comment' },
      },
      diagnostic = create_hls {
        { 'ok',    'DiagnosticOk' },
        { 'warn',  'DiagnosticWarn' },
        { 'error', 'DiagnosticError' },
        { 'info',  'DiagnosticInfo' },
        { 'hint',  'DiagnosticHint' },
      },
      diff = create_hls {
        { 'add',    'DiffAdd' },
        { 'change', 'DiffChange' },
        { 'delete', 'DiffDelete' },
      },
      syntax = create_hls {
        { 'Special', from = 'Special' },
        { 'title', from = 'Title' },
        { 'identifier', from = 'Identifier' },
        { 'type', from = 'Type' },
        { 'structure', from = 'Structure' },
        { 'text', 'Comment' },
        { 'method', 'Constant' },
        { 'fn', 'Constant' },
        { 'constructor', 'Structure' },
        { 'field', 'Identifier' },
        { 'variable', 'Identifier' },
        { 'class', 'Structure' },
        { 'interface', 'Structure' },
        { 'module', 'Keyword' },
        { 'property', 'Keyword' },
        { 'unit', 'Constant' },
        { 'value', 'Constant' },
        { 'enum', 'Constant' },
        { 'keyword', 'Keyword' },
        { 'snippet', 'Comment' },
        { 'color', 'Constant' },
        { 'file', 'Title' },
        { 'reference', 'Identifier' },
        { 'folder', 'Type' },
        { 'enummember', 'Constant' },
        { 'constant', 'Constant' },
        { 'struct', 'Structure' },
        { 'event', 'Keyword' },
        { 'operator', 'Operator' },
        { 'typeparameter', 'Type' },
        { 'namespace', 'Constant' },
        { 'table', 'Structure' },
        { 'object', 'Structure' },
        { 'tag', 'Identifier' },
        { 'array', 'Type' },
        { 'boolean', 'Boolean' },
        { 'number', 'Constant' },
        { 'null', 'Comment' },
        { 'string', 'Comment' },
        { 'package', 'healthWarning' },
      },
    }
  end,
  load = function()
    core.lib.hl = core.lib.hl or {}
    core.lib.hl.__value = require 'core.plugin.hl'.create()

    -- [FIXME]
    ---@deprecated
    core.hl = require 'core.plugin.hl'.create()
  end
}
