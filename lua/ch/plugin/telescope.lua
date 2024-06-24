local builtin = require 'telescope.builtin'
local themes = require 'telescope.themes'

local M = {}

---@alias TelescopeStyle 'dropdown'|'bottom'|'main'

---@type { [TelescopeStyle]: table }
M.style = {}

M.style.dropdown = themes.get_dropdown {
  theme = 'dropdown',
  layout_config = {
    width = function(_, max_columns, _)
      return math.min(max_columns, 80)
    end,
    height = function(_, _, max_lines)
      return math.min(max_lines, 12)
    end,
  },
  previewer = false,
}

M.style.bottom = themes.get_ivy {
  theme = 'bottom',
  -- border = true,
  preview = true,
  shorten_path = true,
  hidden = true,
  prompt_title = '',
  preview_title = '',
  borderchars = {
    preview = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
  },
}

M.style.main = {
  theme = 'main',
  -- winblend = 20;
  layout_config = {
    width = function(_, max_columns, _)
      return math.min(math.floor(max_columns * 0.8), 160)
    end,
    height = function(_, _, max_lines)
      return math.floor(max_lines * 0.9)
    end,
  },
  show_line = false,
  results_title = '',
  prompt_prefix = '$ ',
  prompt_position = 'top',
  prompt_title = '',
  preview_title = '',
  preview_width = 0.4,
}

---@param name TelescopeStyle
---@param opts table
---@return table
M.get_style = function(name, opts)
  opts = opts or {}
  local style = M.style[name]
  return vim.tbl_deep_extend('force', style or {}, opts)
end

M.picker = {}

function M.picker.find_files(props)
  props = props or {}
  local opts = M.get_style('main', {
    prompt_prefix = ch.lib.icons.item.find .. ' ',
    shorten_path = true,
    hidden = true,
  })

  builtin.find_files(MT(opts, props))
end

function M.picker.grep(props)
  props = props or {}
  local opts = M.get_style('main', {
    max_results = 20
  })

  builtin.live_grep(MT(opts, props))
end

-- Explorer

function M.picker.explorer(props)
  props = props or {}
  local opts = M.get_style('dropdown', {
    preview = true,
    shorten_path = true,
    hidden = true,
    prompt_title = '',
    preview_title = '',
  })

  builtin.find_files(MT(opts, props))
end

function M.picker.git_files(props)
  props = props or {}
  builtin.git_files(M.get_style('bottom', props))
end

function M.picker.config_files()
  M.pickers.explorer({
    cwd = '~/.config/nvim',
  })
end

function M.picker.notes()
  M.pickers.explorer({
    cwd = '~/.notes',
  })
end

function M.picker.symbols(props)
  props = props or {}
  local opts = M.get_style('main', {
    shorten_path = true,
    hidden = true,
  })

  builtin.lsp_document_symbols(MT(opts, props))
end

function M.picker.grep_current_file(props)
  props = props or {}
  R 'telescope.builtin'.current_buffer_fuzzy_find(M.get_style('main', props))
end

return M
