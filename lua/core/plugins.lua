local Plugins = {}

-- adapted from @lazy.nvim https://github.com/folke/lazy.nvim/blob/bc620783663ab09d16bff9fdecc07da65b2a1528/lua/lazy/core/plugin.lua#L48
function Plugins.get_name(pkg)
  local name = pkg:sub(-4) == ".git" and pkg:sub(1, -5) or pkg
  name = name:sub(-1) == "/" and name:sub(1, -2) or name
  local slash = name:reverse():find("/", 1, true) --[[@as number?]]
  return slash and name:sub(#name - slash + 2) or pkg:gsub("%W+", "_")
end

return Plugins
