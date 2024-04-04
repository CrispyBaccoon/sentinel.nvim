local Util = require 'core.utils'

local api = vim.api

local model = require 'core.ui.internal.model'({
  items = {},
  module_order = {},
  task_pos = {},
}, {
  title = 'status',
  size = {
    width = 80,
    height = 0.6,
  },
})

function model:init()
  local json_log_path = ('%s.json'):format(core.path.log)
  local fh_json = io.open(json_log_path, 'r')
  if not fh_json then
    Util.log(('could not open log file [%s]'):format(json_log_path), 'error')
    return
  end
  local json_content = vim.json.decode(fh_json:read '*a')
  local _items = {}
  if not json_content or not json_content.items then
    Util.log(
      ('could not deserialize log file [%s]'):format(json_log_path),
      'error'
    )
    return
  end
  _items = json_content.items
  local module_order = {}
  local _module_order = {}
  local items = {}
  for _, item in ipairs(_items) do
    local split = vim.split(item[1], '%.')
    if #split > 1 then
      local module, task = unpack(split, 1, 2)
      if not _module_order[module] then
        _module_order[module] = true
        module_order[#module_order + 1] = module
      end
      items[module] = items[module] or {}
      items[module][task] = items[module][task]
        or { expand = false, items = {} }
      items[module][task].items[#items[module][task].items + 1] =
        { item[2], item[3] }
    end
  end

  self.data.items = items
  self.data.module_order = module_order
  self.data.task_pos = {}

  api.nvim_set_hl(0, 'CoreSpecial', { link = 'Special' })
  api.nvim_set_hl(
    0,
    'CoreModule',
    { fg = core.lib.hl:get('syntax', 'module') }
  )
  api.nvim_set_hl(0, 'CoreTask', { fg = core.lib.hl:get('syntax', 'fn') })
  api.nvim_set_hl(0, 'CoreItem', { fg = core.lib.hl:get('syntax', 'field') })

  self:add_mapping('n', '<cr>', 'open_section')
end

local indent = function(n)
  return string.rep(' ', vim.o.shiftwidth * n)
end

local fmt = function(tpe, ...)
  local fmts = {
    module = ':%s',
    task = core.lib.icons.info.loaded .. ' %s',
    log = function(level, msg)
      if level == 'debug' then
        return (core.lib.icons.ui.item_prefix .. ' %s'):format(msg)
      end
      return (core.lib.icons.ui.item_prefix .. ' [%s] %s'):format(level, msg)
    end,
  }
  local f = fmts[tpe]
  if not f then
    return ''
  end
  if type(f) == 'function' then
    return f(...)
  end
  return f:format(...)
end

function model:view()
  local lines = {}
  self.data.task_pos = {}

  local module_order = self.data.module_order
  local items = self.data.items

  local y = 0
  lines = {}
  for _, module in ipairs(module_order) do
    local module_str = fmt('module', module)
    local prefix = indent(1)
    y = y + 1
    lines[y] = prefix .. module_str
    self:add_hl(
      'Module',
      y,
      string.len(prefix),
      string.len(prefix) + 1 + string.len(module_str) + 1
    )

    for task, task_props in pairs(items[module]) do
      local task_str = fmt('task', task)
      prefix = indent(2)
      y = y + 1
      lines[y] = prefix .. task_str
      self:add_hl('Special', y, string.len(prefix), string.len(prefix) + 3)
      self:add_hl(
        'Task',
        y,
        string.len(prefix) + 3,
        string.len(prefix) + 2 + string.len(task_str)
      )
      self.data.task_pos[y] = { module, task }

      if task_props.expand then
        for _, v in ipairs(task_props.items) do
          local item_str = fmt('log', v[1], v[2])
          prefix = indent(3)
          y = y + 1
          lines[y] = prefix .. item_str
          self:add_hl('Special', y, string.len(prefix), string.len(prefix) + 3)
          self:add_hl(
            'Item',
            y,
            string.len(prefix) + 1,
            string.len(prefix) + 1 + string.len(item_str) + 1
          )
        end
      end
    end
  end

  return lines
end

function model:update(msg)
  local fn = {
    cursormove = function()
      return true
    end,
    open_section = function()
      local item = self.data.task_pos[self.internal.cursor[1]]
      if not item or #item < 2 then
        return
      end
      local module, task = unpack(item, 1, 2)
      self.data.items[module][task].expand =
        not self.data.items[module][task].expand
      return true
    end,
  }

  if not fn[msg] or type(fn[msg]) ~= 'function' then
    return
  end
  return fn[msg]()
end

return model
