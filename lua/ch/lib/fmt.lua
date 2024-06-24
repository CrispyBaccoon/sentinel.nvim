---@class ch.types.lib.fmt
ch.lib.fmt = ch.lib.fmt or {}

---@class ch.types.lib.fmt
---@field space fun(str, n, sep): string
---@param str string
---@param n? integer
---@param sep? string
ch.lib.fmt.space = function(str, n, sep)
  if not n then n = 1 end
  if not sep then sep = ' ' end
  return string.rep(sep, n) .. str .. string.rep(sep, n)
end
