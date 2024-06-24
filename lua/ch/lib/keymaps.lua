---@class ch.types.lib.keymaps
---@field fmt fun(lhs: string): string
ch.lib.keymaps = {}
ch.lib.keymaps.fmt = require 'ch.plugin.keymaps'.fmt

---@class ch.types.lib.keymaps
---@field open_qf_list function
ch.lib.keymaps.open_qf_list = function()
  if ch.lib.options:enabled 'trouble' then
    require("trouble").toggle("quickfix")
  else
    vim.cmd.copen()
  end
end

---@class ch.types.lib.keymaps
---@field register_qf_loader fun(key: string, cb: function, opts: { handle_open?: boolean })
--- *opts*
--- - *handle_open*: if true cb is wrapped in a fn that opens the qf list
ch.lib.keymaps.register_qf_loader = function(key, cb, opts)
  if ch.modules.ch.keymaps.opts.qf_loaders[key] then return end
  if opts.handle_open then
    local _cb = vim.schedule_wrap(cb)
    cb = function()
      _cb()
      ch.lib.keymaps.open_qf_list()
    end
  end
  ch.modules.ch.keymaps.opts.qf_loaders[key] = cb
end
