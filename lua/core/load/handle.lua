local Util = require 'core.utils'

---@class core.types.global
---@field handle core.types.global.handle
---@alias core.types.global.handle table<string, core.types.handle[][]>
core.handle = core.handle or {}

---@class core.types.handle
---@field event string|'custom'
---@field fn AutoCmdCallback
---@field priority? integer
---@field type? string
---@field desc? string

---@diagnostic disable duplicate-doc-alias

---@alias AutoCmdCallback fun(ev: AutoCmdCallbackOpts)
---@class AutoCmdCallbackOpts
---@field id number autocommand id
---@field event string name of the triggered event `autocmd-events`
---@field group number|nil autocommand group id, if any
---@field match string expanded value of `<amatch>`
---@field buf number expanded value of `<abuf>`
---@field file string expanded value of `<afile>`
---@field data any arbitrary data passed from `nvim_exec_autocmds()`

return {
  ---@param event string
  ---@param ev? string
  setup = function (event, ev)
    ev = ev or event
    core.handle[ev] = core.handle[ev] or {}
    vim.api.nvim_create_autocmd(event, {
      group = core.group_id,
      desc = 'core handle for ' .. event,
      pattern = ev ~= event and ev or nil,
      ---@type AutoCmdCallback
      callback = function(opts)
        -- loop over priorities of current event
        vim.iter(pairs(core.handle[ev])):each(function(priority_i, priority_t)
          Util.log('autocmds.callback', string.format('autocmds:%s:%d', ev, priority_i))
          -- loop over handles of current priority
          vim.iter(ipairs(priority_t)):each(function(_, handle)
            handle.fn(opts)
          end)
        end)
      end,
    })
  end,
  --- ```lua
  --- handle.create {
  ---   event = 'ColorScheme', priority = 0,
  ---   fn = function() Util.log 'hi' end,
  --- }
  --- handle.create {
  ---   event = 'custom', type = 'event', priority = 0,
  ---   fn = function() Util.log 'hi' end,
  --- }
  --- ```
  ---@param props core.types.handle
  create = function(props)
    if not props.event or not props.fn then
      return
    end

    -- event name
    local event = props.event
    -- event id
    local ev = props.event
    if event == 'custom' then
      event = 'User'
      ev = props.type
    end

    local priority = props.priority or 50

    if not core.handle[ev] then
      require 'core.load.handle'.setup (event, ev)
    end

    core.handle[ev][priority] = core.handle[ev][priority] or {}
    local next = #core.handle[ev][priority] + 1
    core.handle[ev][priority][next] = props
  end,
  --- trigger a custom event
  start = function(ev)
    Util.log('autocmds.setup', string.format('start:custom:%s', ev))
    vim.api.nvim_exec_autocmds('User', { pattern = ev })
  end,
}
