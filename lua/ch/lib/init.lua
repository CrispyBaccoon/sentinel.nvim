---@alias tuple<T> { [1]: T, [2]: T }

-- statically allocated instead of dynamically by function wrapping
---@class ch.types.lib
---@field autocmd ch.types.lib.autocmd
---@field event ch.types.lib.event
---@field keymaps ch.types.lib.keymaps
---@field hl ch.types.lib.highlight
---@field options ch.types.lib.options
---@field fmt ch.types.lib.fmt
---@field color ch.types.lib.color
---@field math ch.types.lib.math

return {
  setup = function()
    ---@diagnostic disable-next-line: missing-fields
    ch.lib = ch.lib or {}
    require 'ch.lib.preload'
    require 'ch.lib.autocmd'
    require 'ch.lib.event'
    require 'ch.lib.keymaps'
    require 'ch.lib.hl'
    require 'ch.lib.fmt'

    ---@class ch.types.lib
    ---@field get fun(field: string, ...: string): any
    function ch.lib:get(field, ...)
      local query_fn = {
        ---@type fun(...: string): Keymap
        keymaps = function(...) return vim.tbl_get(keymaps, 'prototype', ...) end
      }
      local fn = query_fn[field]
      if fn and type(fn) == 'function' then
        return fn(...)
      end
      if ch.lib[field] and ch.lib[field].get then
        return ch.lib[field]:get(...)
      end
      return nil
    end

    setmetatable(ch.lib,
      {
        __call = ch.lib.get,
      })
  end,
}
