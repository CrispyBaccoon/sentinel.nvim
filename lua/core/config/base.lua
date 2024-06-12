local M = {}

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.cmd('startinsert')
  end,
  desc = 'start insert mode on TermOpen',
})

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.opt_local.number = false
  end,
  desc = 'remove line numbers',
})

require 'core.load.handle'.create {
  event = 'TermOpen', priority = 5,
  desc = 'create quit keymap',
  fn = function(ev)
    vim.keymap.set({ 't' }, '<c-x>q', function()
      return [[<C-\><C-n>]]
    end, { buffer = ev.buf, expr = true })
  end,
}

-- highlight when yanking (copying) text
-- > try it with `yap` in normal mode
-- > see `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank {
      timeout = 200,
    }
  end,
})

-- mkdir path

-- autocmd BufWritePre * call s:Mkdir()
core.lib.autocmd.create {
  event = 'BufWritePre',
  desc = 'create path to file',
  fn = function()
    local dir = vim.fn.expand('<afile>:p:h')

    -- This handles URLs using netrw. See ':help netrw-transparent' for details.
    if dir:find('%l+://') == 1 then
      return
    end

    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
}

-- white space
vim.cmd [[
function! StripTrailingWhitespace()
  if !&binary && &filetype != 'diff'
    normal mz
    normal Hmy
    %s/\s\+$//e
    normal 'yz<CR>
    normal `z
  endif
endfunction
]]

-- statusline
require 'core.plugin.command'.create {
  name = 'ToggleStatusLine', fn = function(_)
  if vim.o.laststatus == 0 then
    vim.opt.laststatus = 3
    vim.opt.cmdheight = core.lib.options:get('options', 'cmdheight')
  else
    vim.opt.laststatus = 0
    vim.opt.cmdheight = 0
  end
end,
}

require 'core.plugin.command'.create {
  name = 'Close', opts = { bang = true }, fn = function(props)
  local buf = vim.api.nvim_get_current_buf()
  if props.bang then
    vim.api.nvim_buf_delete(buf, { force = true })
  else
    local is_changed = vim.fn.getbufinfo(buf)[1].changed == 1
    if is_changed then
      vim.ui.input({ prompt = 'buffer has changes, are you sure? y/N' }, function(input)
        if input == 'yes' or input == 'y' then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end)
    else
      vim.api.nvim_buf_delete(buf, {})
    end
  end
end,
}

---@class BaseConfig
---@field file_associations { [1]: string[], [2]: string, [3]: function }[]

--- Setup options
---@param opts BaseConfig
function M.setup(opts)
  -- { { patterns... }, description, callback }
  for _, item in ipairs(opts.file_associations) do
    if not type(item[1]) == 'table' then
      goto continue
    end
    if not type(item[2]) == 'string' then
      goto continue
    end
    if not type(item[3]) == 'function' then
      goto continue
    end
    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = item[1],
      callback = item[3],
      group = core.group_id,
      desc = item[2],
    })
    ::continue::
  end
end

return M
