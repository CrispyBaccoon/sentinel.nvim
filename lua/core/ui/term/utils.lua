-- adapted from @NvChad https://github.com/NvChad/nvterm/blob/9d7ba3b6e368243175d38e1ec956e0476fd86ed9/lua/nvterm/termutil.lua

local util = {}
local api = vim.api

---calculate window options with float opts
---@param opts vim.api.keyset.win_config
---@return table
util.calc_float_opts = function(opts)
  local width = math.ceil(opts.width * vim.o.columns)
  local height = math.ceil(opts.height * vim.o.lines)
  return {
    relative = 'editor',
    width = width,
    height = height,
    row = opts.row and math.floor(opts.row * vim.o.lines) or (vim.o.lines - height) / 2,
    col = opts.col and math.floor(opts.col * vim.o.columns) or (vim.o.columns - width) / 2,
    border = opts.border or core.config.ui.float_border,
  }
end

---@param type core.types.ui.term.type
---@param ratio number
---@return integer
util.get_split_dims = function(type, ratio)
  local type_switch = type == 'horizontal'
  local type_func = type_switch and api.nvim_win_get_height
    or api.nvim_win_get_width
  return math.floor(type_func(0) * ratio)
end

---@param type core.types.ui.term.type
---@param ui_opts core.types.ui.term.config.ui
---@param override boolean
util.execute_type_cmd = function(type, ui_opts, override)
  local opts = ui_opts[type]
  local dims = type ~= 'float' and util.get_split_dims(type, opts.split_ratio)
    or util.calc_float_opts(opts)
  dims = override and '' or dims
  local type_cmds = {
    horizontal = function()
      vim.cmd(opts.location .. dims .. ' split')
    end,
    vertical = function()
      vim.cmd(opts.location .. dims .. ' vsplit')
    end,
    float = function()
      api.nvim_open_win(0, true, dims)
    end,
  }

  type_cmds[type]()
end

---@param terminals core.types.ui.term.terminal[]
---@return core.types.ui.term.terminal[]
util.verify_terminals = function(terminals)
  return vim.iter(terminals):filter(function(term)
    if not term.buf then return false end
    return vim.api.nvim_buf_is_valid(term.buf)
  end):map(function(term)
      term.open = vim.api.nvim_win_is_valid(term.win)
      return term
    end):totable()
end

return util
