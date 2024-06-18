local Util = {}

--- vim.notify wrapper to avoid msg overload
---@param msg string
---@param level 'debug'|'info'|'warn'|'error'|nil
function Util.log(source, msg, level)
  if core and core.log then
    core.log:write(source, msg, level)
  else
    vim.notify(('[%s] %s'):format(source, msg), ({
      debug = vim.log.levels.DEBUG,
      info = vim.log.levels.INFO,
      warn = vim.log.levels.WARN,
      error = vim.log.levels.ERROR,
    })[level or 'debug'])
    -- > [!NOTE] although debug and info logs are allowed using these before
    -- > core.log (before initialization) could overload the user with
    -- > information everytime they enter neovim
  end
end

---@param name string
function Util.has(name)
  local value = vim.fn.has(name)
  return value == 1
end

---@param plugins string[]
function Util.load_plugins(plugins)
  for _, url in ipairs(plugins) do
    local _url = vim.split(url, '/')
    if #_url > 1 then
      local name = _url[#_url]
      Util.add_to_path(('%s/%s'):format(core.path.lazy, name))
    end
  end
end

---@param path string
function Util.add_to_path(path)
  Util.log('core.utils', ('add "%s" to path'):format(path))
  ---@diagnostic disable-next-line: undefined-field
  vim.opt.rtp:prepend(path)
end

---@param spec LazyPluginSpec
function Util.install(spec)
  local modulepath = spec.dir

  local obj = vim.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/" .. spec.url .. ".git",
    modulepath,
  }, {}):wait()
  if obj.code > 0 then
    Util.log('core.utils', 'error while cloning ' .. spec.name .. ' at ' .. modulepath ..
      '\n\t' .. obj.stdout .. '\n\t' .. obj.stderr, 'error')
    return
  end
  Util.log('core.utils', 'succesfully cloned ' .. spec.name, 'info')
end

---@param spec LazyPluginSpec
function Util.boot(spec)
  if not vim.uv.fs_stat(spec.dir) then
    Util.log('core.utils', ('module %s [%s] not found. bootstrapping...'):format(spec.name, spec.dir), 'warn')
    Util.install(spec)
  end
  Util.add_to_path(spec.dir)
end

---@param props LazyPluginSpec[]
---@return LazyPluginSpec[]
function Util.parse_inputs(props)
  return vim.iter(props):map(function(v)
    if #v == 0 and not v.url then
      return
    end
    v.url = v.url or v[1]
    if not v.name then
      local _url = vim.split(v.url, '/')
      if #_url < 2 then
        return
      end
      v.name = _url[#_url]
    end
    v.dir = v.dir or vim.fs.joinpath(core.path.lazy, v.name)
    return v
  end):totable()
end

function Util.get_diagnostic_signs()
  return {
    [vim.diagnostic.severity.ERROR] = core.lib.icons.diagnostic.error,
    [vim.diagnostic.severity.WARN] = core.lib.icons.diagnostic.warn,
    [vim.diagnostic.severity.INFO] = core.lib.icons.diagnostic.info,
    [vim.diagnostic.severity.HINT] = core.lib.icons.diagnostic.hint,
  }
end

---@param t table
---@param id string[]|string
---@return any
function Util.table_get(t, id)
  if type(id) ~= 'table' then return Util.table_get(t, { id }) end
  local success, res = true, t
  for _, i in ipairs(id) do
    --stylua: ignore start
    success, res = pcall(function() return res[i] end)
    if not success or res == nil then return end
    --stylua: ignore end
  end
  return res
end

return Util
