local api = vim.api

local default_props = {
  title = nil,
  persistent = false,
  text_edit = false,
  float = true,
  size = {
    width = 90,
    height = 0.8,
  },
}

---@class ch.types.ui.model
---@field __index ch.types.ui.model
---@field data table
---@field props ch.types.ui.model.props
---@field internal ch.types.ui.model.internal
---@field _ { blacklist: table<string, boolean> }
local Model = {}

Model.__index = Model

---@class ch.types.ui.model.props
---@field title? string
---@field persistent? boolean
---@field text_edit? boolean
---@field float? boolean
---@field size? { width: integer|number, height: integer|number }

---@class ch.types.ui.model.internal
---@field id integer
---@field ns integer
---@field buf integer
---@field win integer
---@field window { config: table, width: integer, height: integer }
---@field cmd 'quit'|any
---@field cursor tuple<integer>
---@field hls { [string]: ch.types.ui.model.internal.hl_pos[] }

---@alias ch.types.ui.model.internal.hl_pos { [1]: integer, [2]: integer, [3]: integer }

---@class ch.types.ui.model
---@field new fun(self: ch.types.ui.model, data: table, props?: ch.types.ui.model.props): ch.types.ui.model
function Model:new(data, props)
  local model = setmetatable({
    data = data,
    props = vim.tbl_deep_extend('force', default_props, props or {}),
    internal = {
      id = '',
      ns = 0,
      buf = nil,
      win = nil,
      window = { config = {}, width = 0, height = 0 },
      cmd = nil,
      cursor = { 0, 0 },
      hls = {},
    },
    _ = {
      blacklist = {},
    },
  }, self)

  return model
end

---@class ch.types.ui.model
---@field on fun(self: ch.types.ui.model, event: string|string[], fn: function|string, opts: vim.api.keyset.create_autocmd)
function Model:on(event, fn, opts)
  if type(fn) == 'string' then
    local msg = fn
    fn = function()
      self:send(msg)
    end
  end
  opts = vim.tbl_deep_extend('force', {
    group = self.internal.id,
    buffer = self.internal.buf,
    callback = fn,
  }, opts)
  api.nvim_create_autocmd(event, opts)
end

---@class ch.types.ui.model
---@field _init fun(self: ch.types.ui.model)
function Model:_init()
  -- anonymous ns
  local ns = api.nvim_create_namespace ''
  self.internal.ns = ns
  self.internal.id = api.nvim_create_augroup(('ch.ui[%d]'):format(ns), {})

  -- set initial window size
  self.internal.window.height = vim.o.lines
  self.internal.window.width = vim.o.columns

  self.internal.window.config = {
    relative = 'editor',
    title = ch.lib.fmt.space(self.props.title or ''),
    title_pos = self.props.title and 'center' or nil,
    border = 'rounded',
  }
  if not self.props.float then
    self.internal.window.config.title = nil
    self.internal.window.config.title_pos = nil
    self.internal.window.config.border = 'solid'
  end

  self:mount()

  vim.keymap.set('n', 'q', function()
    self:send 'quit'
  end, { buffer = self.internal.buf })

  self:on({ 'BufDelete', 'BufHidden' }, function()
    self:close {}
  end, {
    once = true,
  })
  self:on('CursorMoved', 'cursormove', {})
  if self.props.text_edit then
    self:on('TextChanged', 'text_changed', {})
    self:on('TextChangedI', 'text_changed_insert', {})
  end
end

---@class ch.types.ui.model
---@field layout fun(self: ch.types.ui.model)
function Model:layout()
  local function size(max, value)
    return value > 1 and math.min(value, max) or math.floor(max * value)
  end
  self.internal.window.height = vim.o.lines
  self.internal.window.width = vim.o.columns

  local _height = size(self.internal.window.height, self.props.size.height)
  local _width = size(self.internal.window.width, self.props.size.width)

  if self.props.float then
    self.internal.window.config.row =
      math.floor((self.internal.window.height - _height) / 2)
    self.internal.window.config.col =
      math.floor((self.internal.window.width - _width) / 2)
  else
    self.internal.window.config.row = 0
    self.internal.window.config.col = 0
  end
  self.internal.window.config.width = _width
  self.internal.window.config.height = _height
end

---@class ch.types.ui.model
---@field mount fun(self: ch.types.ui.model)
function Model:mount()
  if self:buf_valid() then
    self.internal.buf = self.internal.buf
  else
    self.internal.buf = api.nvim_create_buf(false, true)
  end

  self:layout()
  self.internal.win =
    api.nvim_open_win(self.internal.buf, true, self.internal.window.config)

  if vim.bo[self.internal.buf].buftype == '' then
    vim.bo[self.internal.buf].buftype = 'nofile'
  end
  local name = self.props.title and 'ch.' .. self.props.title or 'ch'
  if vim.bo[self.internal.buf].filetype == '' then
    vim.bo[self.internal.buf].filetype = name
  end
  vim.g[name .. '_displayed'] = true

  self:opts()

  api.nvim_create_autocmd('VimResized', {
    group = self.internal.id,
    callback = function()
      self:send 'winresize'
    end,
  })
end

---@class ch.types.ui.model
---@field opts fun(self: ch.types.ui.model)
function Model:opts()
  -- buf only options
  api.nvim_set_option_value(
    'modifiable',
    self.props.text_edit,
    { buf = self.internal.buf }
  )
  api.nvim_set_option_value('buflisted', false, { buf = self.internal.buf })

  vim.bo[self.internal.buf].bufhidden = self.props.persistent and 'hide'
    or 'wipe'
  api.nvim_set_option_value('conceallevel', 3, { win = self.internal.win })
  api.nvim_set_option_value('foldenable', false, { win = self.internal.win })
  api.nvim_set_option_value('spell', false, { win = self.internal.win })
  api.nvim_set_option_value('wrap', true, { win = self.internal.win })
  local float_hl = self.props.float and 'NormalFloat' or 'Normal'
  api.nvim_set_option_value(
    'winhighlight',
    'Normal:'..float_hl,
    { win = self.internal.win }
  )
  api.nvim_set_option_value('colorcolumn', '', { win = self.internal.win })
  api.nvim_set_option_value('number', false, { win = self.internal.win })
  api.nvim_set_option_value(
    'relativenumber',
    false,
    { win = self.internal.win }
  )
  api.nvim_set_option_value('signcolumn', 'no', { win = self.internal.win })
  api.nvim_set_option_value('list', false, { win = self.internal.win })
  api.nvim_set_option_value('cul', false, { win = self.internal.win })
end

---@class ch.types.ui.model
---@field focus fun(self: ch.types.ui.model)
function Model:focus()
  api.nvim_set_current_win(self.internal.win)

  if vim.v.vim_did_enter ~= 1 then
    local win = self.internal.win
    api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = function()
        if win and api.nvim_win_is_valid(win) then
          pcall(api.nvim_set_current_win, win)
        end
        return true
      end,
    })
  end
end

---@class ch.types.ui.model
---@field win_valid fun(self: ch.types.ui.model): boolean
function Model:win_valid()
  return self.internal.win and api.nvim_win_is_valid(self.internal.win)
end

---@class ch.types.ui.model
---@field buf_valid fun(self: ch.types.ui.model): boolean
function Model:buf_valid()
  return self.internal.buf and api.nvim_buf_is_valid(self.internal.buf)
end

---@class ch.types.ui.model
---@field hide fun(self: ch.types.ui.model)
function Model:hide()
  if self:win_valid() then
    self:close { wipe = false }
  end
end

---@class ch.types.ui.model
---@field toggle fun(self: ch.types.ui.model): boolean
function Model:toggle()
  if self:win_valid() then
    self:hide()
    return false
  else
    self:show()
    return true
  end
end

---@class ch.types.ui.model
---@field _show fun(self: ch.types.ui.model)
function Model:_show()
  if self:win_valid() then
    self:focus()
    return true
  elseif self:buf_valid() then
    self:mount()
    return true
  end
  return false
end

---@class ch.types.ui.model
---@field show fun(self: ch.types.ui.model, props?: { noerror: boolean })
function Model:show(props)
  local ok = self:_show()
  if ok then
    self:send 'show'
    return true
  end

  if not (props and props.noerror) then
    ch.log('ch.ui.show', 'buffer closed', 'error')
  end

  return false
end

---@class ch.types.ui.model
---@field add_mapping fun(self: ch.types.ui.model, mode, lhs, msg)
---@param mode string
---@param lhs string
---@param msg string
function Model:add_mapping(mode, lhs, msg)
  vim.keymap.set(mode, lhs, function()
    self:send(msg)
  end, {
    desc = ('chui:%s'):format(msg),
    buffer = self.internal.buf,
    silent = true,
  })
end

---@class ch.types.ui.model
---@field _view fun(self: ch.types.ui.model)
function Model:_view()
  self.internal.hls = {}

  local lines = self:view()
  api.nvim_set_option_value('modifiable', true, { buf = self.internal.buf })
  api.nvim_buf_set_lines(self.internal.buf, 0, -1, false, lines)
  api.nvim_set_option_value('modifiable', self.props.text_edit, { buf = self.internal.buf })

  return 'hls'
end

---@class ch.types.ui.model
---@field add_hl fun(self: ch.types.ui.model, name: string, ...)
function Model:add_hl(name, ...)
  self.internal.hls[name] = self.internal.hls[name] or {}
  self.internal.hls[name][#self.internal.hls[name] + 1] = { ... }
end

---@class ch.types.ui.model
---@field _update fun(self: ch.types.ui.model, msg: string): any
function Model:_update(msg)
  local fn = {
    exit = function()
      self:close { wipe = true }
    end,
    quit = function()
      self:close {}
    end,
    view = function()
      return self:_view()
    end,
    winresize = function()
      if
        not (self.internal.win and api.nvim_win_is_valid(self.internal.win))
      then
        return
      end
      self:layout()
      local config = {}
      for _, key in ipairs { 'relative', 'width', 'height', 'col', 'row' } do
        ---@diagnostic disable-next-line: no-unknown
        config[key] = self.internal.window.config[key]
      end
      self:opts()
      api.nvim_win_set_config(self.internal.win, config)
    end,
    cursormove = function()
      self.internal.cursor = api.nvim_win_get_cursor(self.internal.win)
    end,
    hls = function()
      for name, hl_items in pairs(self.internal.hls) do
        for _, v in ipairs(hl_items) do
          local y, x_start, x_end = unpack(v, 1, 3)
          api.nvim_buf_add_highlight(
            self.internal.buf,
            0,
            'ch' .. name,
            y - 1,
            x_start,
            x_end
          )
        end
      end
    end,
  }

  if not msg then
    return
  end

  local cmd = {}

  local _fn = fn[msg]
  if _fn then
    cmd[#cmd + 1] = _fn()
  end

  cmd[#cmd + 1] = self:update(msg)

  return cmd
end

---@class ch.types.ui.model
---@field init fun(self: ch.types.ui.model)
function Model:init() end

---@class ch.types.ui.model
---@field view fun(self: ch.types.ui.model): string[]
function Model:view() end

---@class ch.types.ui.model
---@field update fun(self: ch.types.ui.model, msg)
---@param _ string
function Model:update(_) end

--- used to respond to data changes
---@class ch.types.ui.model
---@field send fun(self: ch.types.ui.model, msg)
---@param msg string
function Model:send(msg)
  if not msg then
    return
  end
  if type(msg) == 'boolean' and msg then
    msg = 'view'
  end
  if self._.blacklist[msg] then
    vim.notify(('stackoverflow on %s'):format(msg), vim.log.levels.WARN)
    return
  end
  self._.blacklist[msg] = true
  local cmds = self:_update(msg)

  for _, cmd in ipairs(cmds) do
    self:send(cmd)
  end

  self._.blacklist[msg] = false
end

---@class ch.types.ui.model
---@field open fun(self: ch.types.ui.model)
function Model:open()
  local ok = self:show { noerror = true }

  if not ok then
    self:_init()
    self:init()
    self:send 'view'
  end
end

---@class ch.types.ui.model
---@field close fun(self: ch.types.ui.model, opts: { wipe?: boolean })
function Model:close(opts)
  local win = self.internal.win
  local buf = self.internal.buf
  local wipe = nil
  if opts and opts.wipe ~= nil then
    wipe = opts.wipe
  else
    wipe = not self.props.persistent
  end

  self.win = nil
  if wipe then
    self.buf = nil
  end
  vim.schedule(function()
    if win and api.nvim_win_is_valid(win) then
      api.nvim_win_close(win, true)
    end
    if wipe and buf and api.nvim_buf_is_valid(buf) then
      api.nvim_buf_delete(buf, { force = true })
    end
  end)
end

return function(...)
  return Model:new(...)
end
