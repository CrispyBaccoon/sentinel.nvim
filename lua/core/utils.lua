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
