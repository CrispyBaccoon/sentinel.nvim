---@class NvimCommandProps
---@field name string Command name
---@field args string The args passed to the command, if any `<args>`
---@field fargs table The args split by unescaped whitespace (when more than one argument is allowed), if any `<f-args>`
---@field nargs string Number of arguments `:command-nargs`
---@field bang boolean "true" if the command was executed with a ! modifier `<bang>`
---@field line1 number The starting line of the command range `<line1>`
---@field line2 number The final line of the command range `<line2>`
---@field range number The number of items in the command range: 0, 1, or 2 `<range>`
---@field count number Any count supplied `<count>`
---@field reg string The optional register, if specified `<reg>`
---@field mods string Command modifiers, if any `<mods>`
---@field smods table Command modifiers in a structured format. Has the same structure as the "mods" key of `nvim_parse_cmd()`.

---@alias chCommand { name: string, fn: fun(props: NvimCommandProps), opts: vim.api.keyset.user_command }

_G.ch.commands = _G.ch.commands or {}

local M = {}

---@param props chCommand
M._add = function(props)
  _G.ch.commands[props.name] = props
  vim.api.nvim_create_user_command(props.name, props.fn, props.opts)
end

--- ```lua
--- require 'ch.plugin.command'.create {
---   name = 'Open', fn = function() ... end,
---   opts = { ... },
--- }
--- ```
---@param props chCommand
M.create = function(props)
  if not props or not props.name or not props.fn then
    return
  end

  local _a = vim.split(props.name, '')

  if #_a == 0 then
    return
  end
  _a[1] = string.upper(_a[1])
  local name = vim.fn.join(_a, '')

  M._add { name = name, fn = props.fn, opts = props.opts or {} }
end

return M
