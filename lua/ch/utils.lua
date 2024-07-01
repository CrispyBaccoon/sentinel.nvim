local Util = {}

---@type fun(source: string, msg: string, level: 'debug'|'info'|'warn'|'error'|nil)
function Util.log(...)
  return ch.log(...)
end

return Util
