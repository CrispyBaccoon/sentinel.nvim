---@return string
local function get_time()
  ---@diagnostic disable-next-line: return-type-mismatch
  return os.date('%Y_%m_%d_%T')
end

local log_levels = {
  debug = vim.log.levels.DEBUG,
  info = vim.log.levels.INFO,
  warn = vim.log.levels.WARN,
  error = vim.log.levels.ERROR,
  [vim.log.levels.DEBUG] = 'debug',
  [vim.log.levels.INFO] = 'info',
  [vim.log.levels.WARN] = 'warn',
  [vim.log.levels.ERROR] = 'error',
}

--- Log Data type
---@class ch.types.log.data
---@field __index ch.types.log.data
---@field items ch.types.log.data.item[]
---@field log_levels { [integer]: string }
local Data = {}

Data.__index = Data

---@class ch.types.log.data
---@field new fun(self: ch.types.log.data): ch.types.log.data
function Data:new()
  local data = setmetatable({
    items = {},
    log_levels = log_levels,
  }, self)

  local json_log_path = ('%s.json'):format(ch.path.log)
  os.remove(json_log_path)

  return data
end

---@alias ch.types.log.data.item { [1]: string, [2]: integer, [3]: string }

---@class ch.types.log.data
---@field write fun(self: ch.types.log.data, props: ch.types.log.data.item)
function Data:write(props)
  if
      (not props[1] or not props[2])
      or (not type(props[1]) == 'integer' or not type(props[2]) == 'string')
  then
    return
  end

  local source, level, msg = unpack(props, 1, 3)
  local item = { source, level, msg }

  -- save to log
  local log_path = ch.path.log
  local fh = io.open(log_path, 'a')
  if not fh then
    vim.notify(
      ('log file can;t be opened: %s'):format(log_path),
      vim.log.levels.ERROR
    )
  else
    local log_line = ('[%s] %s\n'):format(level, msg)
    fh:write(log_line)
    fh:close()
  end

  -- save to json log
  local json_log_path = ('%s.json'):format(ch.path.log)
  local r_fh_json = io.open(json_log_path, 'r')
  local contents = '{"items":{}}'
  if r_fh_json then
    local _contents = r_fh_json:read '*a'
    if type(_contents) == 'string' and string.len(_contents) > 0 then
      contents = _contents
    end
    r_fh_json:close()
  end
  local w_fh_json = io.open(json_log_path, 'w+')
  if not w_fh_json then
    vim.notify(
      ('log file can;t be opened: %s'):format(json_log_path),
      vim.log.levels.ERROR
    )
  else
    local data = vim.json.decode(contents)
    if data == vim.NIL or not data.items or data.items == vim.empty_dict() then
      data.items = {}
    end
    data.items[#data.items+1] = item
    local log_content = vim.json.encode(data)
    w_fh_json:write(log_content)
    w_fh_json:close()
  end
end

--- Log type
---@class ch.types.log
---@field __index ch.types.log
---@field data ch.types.log.data
---@field log_levels { [string]: integer }
local Log = {}

Log.__index = Log

---@class ch.types.log
---@field new fun(self: ch.types.log): ch.types.log
function Log:new()
  local log = setmetatable({
    data = Data:new(),
    log_levels = log_levels,
  }, self)

  local time = get_time()
  log:write('log', ('initial: log start [%s]'):format(time))

  return log
end

---@class ch.types.log
---@field write fun(self: ch.types.log, source: string, msg: string, level: 'debug'|'info'|'warn'|'error'|nil)
function Log:write(source, msg, level)
  level = level or 'debug'
  local log_level = self.log_levels[level] or self.log_levels['debug']
  self.data:write({ source, level, msg })

  -- notify
  if log_level < ch.config.log_level then
    return
  end
  vim.notify(('[%s] %s'):format(source, msg), log_level)
end

---@class ch.types.log
---@field __call fun(self: ch.types.log, source: string, msg: string, level: 'debug'|'info'|'warn'|'error'|nil)
function Log:__call(...)
  return self:write(...)
end

---@class ch.types.global
---@field log ch.types.log
---@type ch.types.log
_G.ch.log = Log:new()
