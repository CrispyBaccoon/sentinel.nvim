local Util = require 'ch.utils'

local Plugins = {}

-- adapted from @lazy.nvim https://github.com/folke/lazy.nvim/blob/bc620783663ab09d16bff9fdecc07da65b2a1528/lua/lazy/ch/plugin.lua#L48
function Plugins.get_name(pkg)
  local name = pkg:sub(-4) == ".git" and pkg:sub(1, -5) or pkg
  name = name:sub(-1) == "/" and name:sub(1, -2) or name
  local slash = name:reverse():find("/", 1, true) --[[@as number?]]
  return slash and name:sub(#name - slash + 2) or pkg:gsub("%W+", "_")
end

---@param plugins string[]
function Plugins.load_plugins(plugins)
  vim.iter(plugins):each(function(url)
    local name = Plugins.get_name(url)
    Plugins.add_to_path(('%s/%s'):format(ch.path.lazy, name))
  end)
end

---@param path string
function Plugins.add_to_path(path)
  Util.log('ch.plugins', ('add "%s" to path'):format(path))
  ---@diagnostic disable-next-line: undefined-field
  vim.opt.rtp:prepend(path)
end

---@param spec LazyPluginSpec
function Plugins.install(spec)
  local modulepath = spec.dir

  local obj = vim.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/" .. spec.url .. ".git",
    modulepath,
  }, {}):wait()
  if obj.code > 0 then
    Util.log('ch.plugins', 'error while cloning ' .. spec.name .. ' at ' .. modulepath ..
      '\n\t' .. obj.stdout .. '\n\t' .. obj.stderr, 'error')
    return
  end
  Util.log('ch.plugins', 'succesfully cloned ' .. spec.name, 'info')
end

---@param spec LazyPluginSpec
function Plugins.bootstrap(spec)
  if not vim.uv.fs_stat(spec.dir) then
    Util.log('ch.plugins', ('module %s [%s] not found. bootstrapping...'):format(spec.name, spec.dir), 'warn')
    Plugins.install(spec)
  end
  Plugins.add_to_path(spec.dir)
end

function Plugins.load(name)
  local spec = vim.iter(ch._inputs):find(function(v)
    return v.name == name
  end)
  if not spec then
    Util.log('ch.plugins', ('could not find input \'%s\''):format(name))
    return
  end
  Plugins.bootstrap(spec)
end

---@param props LazyPluginSpec[]
---@return LazyPluginSpec[]
function Plugins.parse_inputs(props)
  return vim.iter(props):map(function(v)
    if #v == 0 and not v.url then
      return
    end
    v.url = v.url or ('https://github.com/%s.git'):format(v[1])
    if not v.name then
      v.name = Plugins.get_name(v.url)
    end
    v.dir = v.dir or vim.fs.joinpath(ch.path.lazy, v.name)
    return v
  end):totable()
end

return Plugins
