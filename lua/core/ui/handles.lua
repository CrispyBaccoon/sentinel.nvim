local Util = require 'core.utils'

local api = vim.api

local model = require 'core.ui.internal.model'({
  items = {},
  task_pos = {},
}, {
  title = 'handles',
  size = {
    width = 80,
    height = 0.6,
  },
})

function model:init()
  local _items = core.handle
  ---@type table<string, { expand: boolean, items: core.types.handle[]}[]>
  local items = {}
  for event, event_t in pairs(_items) do
    items[event] = vim.iter(event_t):map(function(t)
      return {
        expand = false,
        items = t,
      }
    end):totable()
  end

  self.data.items = items
  self.data.task_pos = {}

  api.nvim_set_hl(0, 'CoreSpecial', { link = 'Special' })
  api.nvim_set_hl(0, 'CoreEvent', { fg = core.lib.hl:get('syntax', 'event') })
  api.nvim_set_hl(0, 'CoreTask', { fg = core.lib.hl:get('syntax', 'fn') })
  api.nvim_set_hl(0, 'CoreItem', { fg = core.lib.hl:get('syntax', 'field') })

  self:add_mapping('n', '<cr>', 'open_section')
end

local indent = function(n)
  return string.rep(' ', vim.o.shiftwidth * n)
end

local fmt = function(tpe, ...)
  local fmts = {
    event = core.lib.icons.syntax.event..' %s',
    priority = function(priority)
      return (core.lib.icons.info.loaded .. ' %s'):format(priority)
    end,
    task = function(desc)
      return (core.lib.icons.info.loaded .. ' %s'):format(desc or core.lib.icons.syntax.fn)
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

  ---@type table<string, { expand: boolean, items: core.types.handle[]}[]>
  local items = self.data.items

  local y = 0
  lines = {}
  for event, event_t in pairs(items) do
    local event_str = fmt('event', event)
    local prefix = indent(1)
    y = y + 1
    lines[y] = prefix .. event_str
    self:add_hl(
      'Event',
      y,
      string.len(prefix),
      string.len(prefix) + 1 + string.len(event_str) + 1
    )

    for priority_i, priority_t in pairs(event_t) do
      local task_str = fmt('priority', priority_i)
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
      self.data.task_pos[y] = { event, priority_i }

      if priority_t.expand then
        for _, v in ipairs(priority_t.items) do
          local item_str = fmt('task', v.desc)
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
      local event, task = unpack(item, 1, 2)
      self.data.items[event][task].expand =
        not self.data.items[event][task].expand
      return true
    end,
  }

  if not fn[msg] or type(fn[msg]) ~= 'function' then
    return
  end
  return fn[msg]()
end

return model
