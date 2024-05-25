-- adapted from @NvChad https://github.com/NvChad/nvterm/blob/9d7ba3b6e368243175d38e1ec956e0476fd86ed9/lua/nvterm/terminal.lua

local util = require 'core.ui.term.utils'
local api = vim.api
local chaiterm = {}
---@type core.types.ui.term.terminal[]
local terminals = {}

---@param list core.types.ui.term.terminal[]?
---@return core.types.ui.term.terminal?
local function get_last(list)
  if list then
    return not vim.tbl_isempty(list) and list[#list] or nil
  end
  return terminals[#terminals] or nil
end

---@param type core.types.ui.term.type
---@param list core.types.ui.term.terminal[]?
---@return core.types.ui.term.terminal[]
local function get_type(type, list)
  list = list or terminals
  return vim.iter(list):filter(function(t)
    return t.type == type
  end):totable()
end

local function get_still_open()
  if not terminals then
    return {}
  end
  return vim.iter(terminals):filter(function(t)
    return t.open == true
  end):totable()
end

local function get_last_still_open()
  return get_last(get_still_open())
end

local function get_type_last(type)
  return get_last(get_type(type))
end

local function get_term(key, value)
  -- assumed to be unique, will only return 1 term regardless
  return vim.iter(terminals):filter(function(t)
    return t[key] == value
  end):next()
end

local create_term_window = function(type)
  local existing = terminals and #get_type(type, get_still_open()) > 0
  util.execute_type_cmd(
    type,
    core.lib.options:get('ui', 'terminal', 'ui'),
    existing
  )
  vim.wo.relativenumber = false
  vim.wo.number = false
  vim.wo.winhl = 'Normal:Normal'
  return api.nvim_get_current_win()
end

local ensure_and_send = function(cmd, type)
  terminals = util.verify_terminals(terminals)
  local function select_term()
    if not type then
      return get_last_still_open() or chaiterm.new 'horizontal'
    else
      return get_type_last(type) or chaiterm.new(type)
    end
  end
  local term = select_term()
  api.nvim_chan_send(term.job_id, cmd .. '\n')
end

local call_and_restore = function(fn, opts)
  local current_win = api.nvim_get_current_win()
  local mode = api.nvim_get_mode().mode == 'i' and 'startinsert' or 'stopinsert'

  fn(unpack(opts))
  api.nvim_set_current_win(current_win)

  vim.cmd(mode)
end

chaiterm.send = function(cmd, type)
  if not cmd then
    return
  end
  call_and_restore(ensure_and_send, { cmd, type })
end

chaiterm.hide_term = function(term)
  terminals[term.id].open = false
  api.nvim_win_close(term.win, false)
end

chaiterm.show_term = function(term)
  term.win = create_term_window(term.type)
  api.nvim_win_set_buf(term.win, term.buf)
  terminals[term.id].open = true
  vim.cmd 'startinsert'
end

chaiterm.get_and_show = function(key, value)
  local term = get_term(key, value)
  chaiterm.show_term(term)
end

chaiterm.get_and_hide = function(key, value)
  local term = get_term(key, value)
  chaiterm.hide_term(term)
end

chaiterm.hide = function(type)
  local term = type and get_type_last(type) or get_last()
  chaiterm.hide_term(term)
end

chaiterm.show = function(type)
  terminals = util.verify_terminals(terminals)
  local term = type and get_type_last(type) or terminals.last
  chaiterm.show_term(term)
end

chaiterm.new = function(type, shell_override)
  local win = create_term_window(type)
  local buf = api.nvim_create_buf(false, true)
  api.nvim_set_option_value('filetype', 'terminal', { buf = buf })
  api.nvim_set_option_value('buflisted', false, { buf = buf })

  api.nvim_set_option_value('cursorline', false, { win = win })
  api.nvim_set_option_value('signcolumn', 'no', { win = win })
  api.nvim_win_set_buf(win, buf)

  local job_id = vim.fn.termopen(vim.o.shell or shell_override)
  local id = #terminals + 1
  local term =
    { id = id, win = win, buf = buf, open = true, type = type, job_id = job_id }
  terminals[id] = term
  vim.cmd 'startinsert'
  return term
end

chaiterm.toggle = function(type)
  terminals = util.verify_terminals(terminals)
  local term = get_type_last(type)

  if not term then
    term = chaiterm.new(type)
  elseif term.open then
    chaiterm.hide_term(term)
  else
    chaiterm.show_term(term)
  end
end

chaiterm.toggle_all_terms = function()
  terminals = util.verify_terminals(terminals)

  for _, term in ipairs(terminals.list) do
    if term.open then
      chaiterm.hide_term(term)
    else
      chaiterm.show_term(term)
    end
  end
end

chaiterm.close_all_terms = function()
  for _, buf in ipairs(chaiterm.list_active_terms 'buf') do
    vim.cmd('bd! ' .. tostring(buf))
  end
end

chaiterm.list_active_terms = function(property)
  local terms = get_still_open()
  if property then
    return vim.iter(terms):map(function(t)
      return t[property]
    end):totable()
  end
  return terms
end

chaiterm.list_terms = function()
  return terminals
end

chaiterm.init = function(term_config)
  terminals = term_config
end

return chaiterm
