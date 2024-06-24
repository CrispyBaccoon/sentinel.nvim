---@class ch.types.lib.options
ch.lib.options = ch.lib.options or {}
ch.lib.options.__value = ch.lib.options.__value or {}

---@class ch.types.lib.options
---@field get fun(self, name: string, ...: string): any
function ch.lib.options:get(name, ...)
  if not name then return end
  local query = { ... }
  if #query == 0 then return end
  local module = self.__value[name]
  if module and type(module.opts) == 'table' then
    ---@diagnostic disable-next-line: param-type-mismatch
    return vim.tbl_get(module.opts, ...)
  end
end

---@class ch.types.lib.options
---@field enabled fun(self, name: string): any
function ch.lib.options:enabled(name)
  if not name then return end
  local module = self.__value[name]
  if module then
    ---@diagnostic disable-next-line: undefined-field
    if module.enabled == false then
      return false
    end
    return true
  end
  return false
end
