local Util = {}

--- vim.notify wrapper to avoid msg overload
---@param msg string
---@param level 'debug'|'info'|'warn'|'error'|nil
function Util.log(source, msg, level)
  if ch and ch.log then
    ch.log:write(source, msg, level)
  else
    vim.notify(('[%s] %s'):format(source, msg), ({
      debug = vim.log.levels.DEBUG,
      info = vim.log.levels.INFO,
      warn = vim.log.levels.WARN,
      error = vim.log.levels.ERROR,
    })[level or 'debug'])
    -- > [!NOTE] although debug and info logs are allowed using these before
    -- > ch.log (before initialization) could overload the user with
    -- > information everytime they enter neovim
  end
end

---@param name string
function Util.has(name)
  local value = vim.fn.has(name)
  return value == 1
end

return Util
