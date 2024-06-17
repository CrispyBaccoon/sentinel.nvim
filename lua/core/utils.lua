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

---@param props { name: string, url: string }
function Util.git_clone(props)
  local modulepath = core.path[props.name]

  local obj = vim.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/" .. props.url .. ".git",
    modulepath,
  }, { cwd = core.path.root }):wait()
  if obj.code > 0 then
    Util.log('core.utils', 'error while cloning ' .. props.name .. ' at ' .. modulepath ..
      '\n\t' .. obj.stdout .. '\n\t' .. obj.stderr, 'error')
    return
  end
  Util.log('core.utils', 'succesfully cloned ' .. props.name, 'info')
end

---@param props { name: string, dir: string, mod: string, opts: table|nil|boolean }
function Util.boot(props)
  if not vim.loop.fs_stat(core.path[props.name]) then
    Util.log('core.utils', 'module ' .. props.name .. ' not found. bootstrapping...', 'warn')
    require 'core.bootstrap'.load(props.name)
  end
  Util.add_to_path(core.path[props.name])

  if props.opts == false then
    return
  end

  local ok, result = SR(props.mod)

  if ok then
    if props.opts then
      result.setup(props.opts)
    end
    return
  end

  Util.log('core.utils', 'error while bootstrapping ' .. props.name .. '\n\t' .. (result or ''), 'error')
end

---@param props { name: string, dir: string, mod: string, url: string, opts: table|nil|boolean }
---@return { boot: function, load: function, update: function }|nil
function Util.create_bootstrap(props)
  if not props.name then
    Util.log('core.utils', 'error while loading bootstrap spec\n\t`props.name` is empty', 'error')
    return
  end
  if not props.url then
    Util.log('core.utils', 'error while loading bootstrap spec\n\t`props.url` is empty', 'error')
    return
  end
  props.dir = props.dir or props.name
  props.mod = props.mod or props.name

  local dir = core.path.lazy .. '/' .. props.dir
  core.path[props.name] = dir

  return {
    boot = function()
      Util.boot { name = props.name, dir = props.dir, mod = props.mod, opts = props.opts }
    end,
    load = function()
      Util.git_clone { name = props.name, url = props.url }
    end,
    update = function()
      Util.git_pull {
        name = props.name,
        path = core.path[props.name],
      }
    end,
  }
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
