---@class ch.types.global
---@field handle ch.types.global.handle
---@alias ch.types.global.handle table<string, ch.types.handle[][]>
ch.handle = ch.handle or {}

---@class ch.types.handle
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
    ch.handle[ev] = ch.handle[ev] or {}
    vim.api.nvim_create_autocmd(event, {
      group = ch.group_id,
      desc = 'ch handle for ' .. event,
      pattern = ev ~= event and ev or nil,
      ---@type AutoCmdCallback
      callback = function(opts)
        -- loop over priorities of current event
        vim.iter(pairs(ch.handle[ev])):each(function(priority_i, priority_t)
          ch.log('autocmds.callback', string.format('autocmds:%s:%d', ev, priority_i))
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
  ---   fn = function() ch.log 'hi' end,
  --- }
  --- handle.create {
  ---   event = 'custom', type = 'event', priority = 0,
  ---   fn = function() ch.log 'hi' end,
  --- }
  --- ```
  ---@param props ch.types.handle
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

    if not ch.handle[ev] then
      require 'ch.load.handle'.setup (event, ev)
    end

    ch.handle[ev][priority] = ch.handle[ev][priority] or {}
    local next = #ch.handle[ev][priority] + 1
    ch.handle[ev][priority][next] = props
  end,
  --- trigger a custom event
  start = function(ev)
    ch.log('autocmds.setup', string.format('start:custom:%s', ev))
    vim.api.nvim_exec_autocmds('User', { pattern = ev })
  end,
}
