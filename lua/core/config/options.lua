local M = {}

local default_cursor_style = 'block'

local function get_cursor_style_value(style)
  if type(style) == 'string' and style == 'block' then
    return 'block'
  end

  if #style ~= 2 then return default_cursor_style end

  if type(style[1]) ~= 'string' or type(style[2]) ~= 'number' then return default_cursor_style end

  local styles = {
    bar = 'ver',
    underscore = 'hor',
  }
  return ('%s%s'):format(styles[style[1]], style[2])
end

---@class OptionsConfig
---@field cursorline boolean
---@field number boolean|'relative'
---@field tab_width integer
---@field scrolloff integer
---@field use_ripgrep boolean
---@field treesitter_folds boolean
---@field load_plugins string[]
---@field cmdheight boolean
---@field cursorstyle table<'normal'|'insert'|'replace','string'|{[1]: string, [2]: integer}>
---@field clipboard 'system'|'selection'

--- Setup options
---@param opts OptionsConfig
function M.setup(opts)
  vim.opt.encoding = 'utf-8'
  vim.opt.fileencoding = 'utf-8'

  -- basic UI
  vim.opt.title = true
  vim.o.titlestring = '%f · nvim'
  vim.opt.errorbells = false
  vim.opt.mouse = 'nv'

  vim.opt.guicursor = ('n-v-sm:%s-NCursor,i-c-ci-ve:%s-ICursor,r-cr-o:%s-RCursor'):format(
    get_cursor_style_value(opts.cursorstyle.normal),
    get_cursor_style_value(opts.cursorstyle.insert),
    get_cursor_style_value(opts.cursorstyle.replace)
  )
  vim.opt.cursorline = opts.cursorline
  vim.opt.showmode = false
  vim.opt.showcmd = false
  vim.opt.cmdheight = opts.cmdheight

  vim.opt.number = true
  vim.opt.relativenumber = false
  if opts.number == false then
    vim.opt.number = false
    vim.opt.relativenumber = false
  end
  if opts.number == 'relative' then
    vim.opt.relativenumber = true
  end
  vim.opt.numberwidth = 3
  vim.opt.signcolumn = 'yes:1'
  vim.opt.smarttab = true

  vim.opt.pumheight = 5
  vim.opt.wildoptions = { 'fuzzy', 'pum', 'tagfile' }
  vim.opt.wildmode = 'longest:full,full'

  vim.opt.conceallevel = 2
  vim.opt.concealcursor = 'c'

  vim.opt.shortmess = 'filnrxoOtTIF'
  vim.opt.formatoptions = 'tcrqj'

  -- allow cursor to move paste the end of the line in visual block mode
  vim.opt.virtualedit = 'block'

  vim.o.timeout = true
  vim.o.timeoutlen = 300

  -- indention
  vim.opt.cindent = true
  vim.opt.smartindent = true

  -- no tab indention
  vim.opt.tabstop = opts.tab_width
  vim.opt.softtabstop = 1
  vim.opt.shiftwidth = opts.tab_width
  vim.opt.expandtab = true

  -- Lifecycle
  vim.opt.shell = vim.env['SHELL'] or '/usr/bin/bash'
  vim.opt.swapfile = false
  vim.opt.backup = false
  vim.opt.undodir = vim.fn.stdpath 'state' .. '/undodir'
  vim.opt.undofile = true
  vim.opt.hidden = true

  -- Searching
  vim.opt.grepprg = opts.use_ripgrep and 'rg --vimgrep'
    or 'grep -n $* /dev/null'
  vim.opt.grepformat = '%f:%l:%c:%m'
  vim.opt.incsearch = true
  vim.opt.hlsearch = false
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  -- substitution with preview window
  vim.opt.inccommand = 'split'

  -- Clipboard
  local clipboardstyles = {
    system = 'unnamedplus', -- '+'
    selection = 'unnamed', -- '*'
  }
  vim.opt.clipboard = clipboardstyles[opts.clipboard]

  -- Scrolling
  vim.opt.scrolloff = opts.scrolloff
  vim.opt.sidescrolloff = opts.scrolloff

  -- Folding
  vim.opt.foldenable = true
  vim.opt.foldlevelstart = 0
  vim.opt.foldnestmax = 4
  vim.opt.foldmethod = 'marker'
  if opts.treesitter_folds then
    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.opt.foldenable = false
  end

  -- window splits
  vim.opt.splitright = true
  vim.opt.splitbelow = true

  vim.iter(ipairs { 'menu', 'menuone', 'noselect', 'preview' }):each(function(_, option)
    if not vim.tbl_contains(vim.opt.completeopt, option) then
      vim.opt.completeopt:append(option)
    end
  end)

  -- by default unload all vim plugins
  local loaded_plugins = {
    'zipPlugin',
    'zip',
    'tarPlugin',
    'tar',
    'gzip',
    'tutor_mode_plugin',
    'matchit',
  }
  vim.iter(ipairs(loaded_plugins)):each(function(_, k)
    if opts.load_plugins and opts.load_plugins[k] then
      vim.g['loaded_' .. k] = 0
    else
      vim.g['loaded_' .. k] = 1
    end
  end)
end

return M
