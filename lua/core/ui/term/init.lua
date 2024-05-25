-- adapted from @NvChad https://github.com/NvChad/nvterm/blob/9d7ba3b6e368243175d38e1ec956e0476fd86ed9/lua/nvterm/init.lua

---@alias core.types.ui.term.type 'horizontal'|'vertical'|'float'

---@class core.types.ui.term.config
---@field enabled boolean
---@field terminals core.types.ui.term.config.terminals
---@field ui core.types.ui.term.config.ui

---@class core.types.ui.term.terminal
---@field open boolean
---@field buf integer
---@field win integer
---@field job_id integer

---@class core.types.ui.term.config.terminals
---@field list core.types.ui.term.terminal[]

---@class core.types.ui.term.config.ui
---@field float vim.api.keyset.win_config
---@field horizontal core.types.ui.term.config.ui.split_opts
---@field vertical core.types.ui.term.config.ui.split_opts
---@class core.types.ui.term.config.ui.split_opts
---@field location 'rightbelow'|'leftabove'|'left'|'right'
---@field split_ratio number

local M = {}
local api = vim.api

M.set_behavior = function(behavior)
  if behavior.autoclose_on_quit.enabled then
    local function force_exit()
      require('core.ui.term.terminal').close_all_terms()
      api.nvim_command 'qa'
    end
    api.nvim_create_autocmd({ 'WinClosed' }, {
      callback = vim.schedule_wrap(function()
        local open_terms =
          require('core.ui.term.terminal').list_active_terms 'win'

        local non_terms = vim.iter(api.nvim_list_wins()):filter(function(win)
          return not vim.tbl_contains(open_terms, win)
        end)

        if not vim.tbl_isempty(non_terms) then
          return
        end

        if not behavior.autoclose_on_quit.confirm then
          return force_exit()
        end

        vim.ui.input(
          { prompt = 'Close all terms and quit? (y/N): ' },
          function(input)
            if not input or not string.lower(input) == 'y' then
              return
            end
            force_exit()
          end
        )
      end),
    })
  end
  if behavior.close_on_exit then
    api.nvim_create_autocmd({ 'TermClose' }, {
      callback = function(ev)
        api.nvim_buf_call(
          ev.buf,
          vim.schedule_wrap(function()
            api.nvim_input '<CR>'
          end)
        )
      end,
    })
  end

  if behavior.auto_insert then
    api.nvim_create_autocmd({ 'BufEnter' }, {
      callback = function()
        vim.cmd 'startinsert'
      end,
      pattern = 'term://*',
    })

    api.nvim_create_autocmd({ 'BufLeave' }, {
      callback = function()
        vim.cmd 'stopinsert'
      end,
      pattern = 'term://*',
    })
  end
end

M.setup = function(opts)
  require('core.ui.term').set_behavior(opts.behavior)
  require('core.ui.term.terminal').init(opts.terminals)
end

M.setup_keymaps = function(opts)
  Keymap.group {
    group = 'terminal',
    {
      'normal',
      opts.mappings.open_float,
      function()
        require('core.ui.term.terminal').toggle 'float'
      end,
      'toggle floating terminal',
    },
    {
      'normal',
      opts.mappings.open_vertical,
      function()
        require('core.ui.term.terminal').toggle 'vertical'
      end,
      'toggle vertical terminal',
    },
    {
      'normal',
      opts.mappings.open_horizontal,
      function()
        require('core.ui.term.terminal').toggle 'horizontal'
      end,
      'toggle horizontal terminal',
    },
  }
  vim.keymap.set('t', opts.mappings.open_float, function()
    require('core.ui.term.terminal').toggle 'float'
  end, { desc = 'toggle floating terminal' })
  vim.keymap.set('t', opts.mappings.open_vertical, function()
    require('core.ui.term.terminal').toggle 'vertical'
  end, { desc = 'toggle vertical terminal' })
  vim.keymap.set('t', opts.mappings.open_horizontal, function()
    require('core.ui.term.terminal').toggle 'horizontal'
  end, { desc = 'toggle horizontal terminal' })
end

return M
