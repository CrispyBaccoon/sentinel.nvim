local api = vim.api

local model = require 'core.ui.internal.model'({
  header = {},
  buttons = {},
  width = 0,
  max_height = 0,
  header_start_index = 0,
  abc = 0,
  keybind_linenr = {},
  cursor_init = false,
}, {
  title = 'dash',
  float = false,
  size = {
    width = 1,
    height = 1,
  },
})

---@class DashConfig
---@field open_on_startup boolean
---@field header string[]
---@field buttons { [1]: string, [2]: string, [3]: string|function }[]

function model:init()
  ---@type DashConfig
  local config = core.modules.core.dash.opts
  -- setup variables
  local buttons = vim.deepcopy(config.buttons)
  if type(config.buttons) == 'function' then
    buttons = config.buttons()
  end
  self.data.buttons = buttons

  -- view
  local headerAscii = vim.deepcopy(config.header)
  local emmptyLine = string.rep(' ', vim.fn.strwidth(headerAscii[1]))

  table.insert(headerAscii, 1, emmptyLine)
  table.insert(headerAscii, 2, emmptyLine)

  headerAscii[#headerAscii + 1] = emmptyLine
  headerAscii[#headerAscii + 1] = emmptyLine

  self.data.header = headerAscii

  local min_width = 36
  local dashWidth = #headerAscii[1] + 3
  if dashWidth < min_width then
    dashWidth = min_width
  end

  self.data.width = dashWidth

  self.data.max_height = #headerAscii + 4 + (2 * #buttons) -- 4  = extra spaces i.e top/bottom

  api.nvim_set_hl(0, 'CoreDashAscii', { link = 'TablineSel' })
  api.nvim_set_hl(0, 'CoreDashButtons', { link = 'Comment' })

  for _, key in ipairs { 'h', 'l', '<left>', '<right>', '<up>', '<down>' } do
    self:add_mapping('n', key, '')
  end

  self:add_mapping('n', 'q', 'exit')
  self:add_mapping('n', 'j', 'move_down')
  self:add_mapping('n', 'k', 'move_up')

  -- pressing enter on
  self:add_mapping('n', '<CR>', 'enter')
end

function model:view()
  local header = self.data.header
  local buttons = self.data.buttons
  local max_height = self.data.max_height

  local function addSpacing_toBtns(txt1, txt2)
    local btn_len = vim.fn.strwidth(txt1) + vim.fn.strwidth(txt2)
    local spacing = self.data.width - btn_len
    return txt1 .. string.rep(' ', spacing - 1) .. txt2 .. ' '
  end

  local function addPadding_toHeader(str)
    local start_padding = (self.internal.window.width - vim.fn.strwidth(str))
      / 2
    local end_padding = (self.data.width - vim.fn.strwidth(str)) / 2 + 1
    return string.rep(' ', math.floor(start_padding))
      .. str
      .. string.rep(' ', math.floor(end_padding))
  end

  local dashboard = {}

  for _, val in ipairs(header) do
    table.insert(dashboard, val .. ' ')
  end

  for _, val in ipairs(buttons) do
    local desc = val[1]
    local lhs = core.lib.keymaps.fmt(val[2])
    table.insert(dashboard, addSpacing_toBtns(desc, lhs) .. ' ')
    table.insert(dashboard, header[1] .. ' ')
  end

  local result = {}

  -- make all lines available
  for i = 1, math.max(self.internal.window.height, max_height) do
    result[i] = ''
  end

  local headerStart_Index = math.abs(
    math.floor((self.internal.window.height / 2) - (#dashboard / 2))
  ) + 1 -- 1 = To handle zero case
  local abc = math.abs(
    math.floor((self.internal.window.height / 2) - (#dashboard / 2))
  ) + 1 -- 1 = To handle zero case
  self.data.abc = abc

  self:send 'update_keybind_linenr'

  -- set ascii
  for _, val in ipairs(dashboard) do
    result[headerStart_Index] = addPadding_toHeader(val)
    headerStart_Index = headerStart_Index + 1
  end
  self.data.header_start_index = headerStart_Index

  local horiz_pad_index = math.floor(
    (self.internal.window.width / 2) - (self.data.width / 2)
  ) - 2

  for i = abc, abc + #header - 3 do
    self:add_hl('DashAscii', i, horiz_pad_index, -1)
  end

  for i = abc + #header - 2, abc + #dashboard do
    self:add_hl('DashButtons', i, horiz_pad_index, -1)
  end

  return result
end

function model:update(msg)
  local fn = {
    -- hls acts as a fixup here
    hls = function()
      if not self.data.cursor_init then
        self:send 'cursor_init'
      end
    end,
    cursor_init = function()
      api.nvim_win_set_cursor(self.internal.win, {
        self.data.abc + #self.data.header,
        math.floor((vim.o.columns - self.data.width) / 2) - 2,
      })
      self.data.cursor_init = true
    end,
    update_keybind_linenr = function()
      local first_btn_line = self.data.abc + #self.data.header + 2
      local keybind_lineNrs = {}

      for _, _ in ipairs(self.data.buttons) do
        table.insert(keybind_lineNrs, first_btn_line - 2)
        first_btn_line = first_btn_line + 2
      end

      self.data.keybind_linenr = keybind_lineNrs
    end,
    move_down = function()
      local linenrs = self.data.keybind_linenr
      local cur = vim.fn.line '.'
      local target_line = cur == linenrs[#linenrs] and linenrs[1] or cur + 2
      api.nvim_win_set_cursor(
        self.internal.win,
        { target_line, math.floor((vim.o.columns - self.data.width) / 2) - 2 }
      )
    end,
    move_up = function()
      local linenrs = self.data.keybind_linenr
      local cur = vim.fn.line '.'
      local target_line = cur == linenrs[1] and linenrs[#linenrs] or cur - 2
      api.nvim_win_set_cursor(
        self.internal.win,
        { target_line, math.floor((vim.o.columns - self.data.width) / 2) - 2 }
      )
    end,
    enter = function()
      local find_action = function()
        for i, val in ipairs(self.data.keybind_linenr) do
          if val == vim.fn.line '.' then
            local action = self.data.buttons[i][3]

            if type(action) == 'string' then
              return function()
                vim.cmd(action)
              end
            elseif type(action) == 'function' then
              return function()
                action()
              end
            end
          end
        end
      end

      local cb = vim.schedule_wrap(find_action())
      self:send 'exit'
      cb()
    end,
  }

  if not fn[msg] or type(fn[msg]) ~= 'function' then
    return
  end
  return fn[msg]()
end

local M = {}

function M.open()
  model:open()
end

return M
