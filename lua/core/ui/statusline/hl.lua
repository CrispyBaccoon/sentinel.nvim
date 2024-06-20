local M = {}

M.setup_highlights = function()
  core.lib.autocmd.create {
    event = 'ColorScheme', priority = GC.priority.handle.colorscheme.plugin,
    desc = 'load statusline hls',
    fn = function(_)
      require 'core.ui.statusline.hl'.apply_highlights()
    end
  }
end

---@param palette table<'normal'|'insert'|'visual'|'command', { a?: vim.api.keyset.hl_info, b?: vim.api.keyset.hl_info, c?: vim.api.keyset.hl_info }>
---@return boolean success
local function apply_palette(palette)
  local fallback = palette.normal
  for _, s in ipairs({'a', 'b', 'c'}) do
    if not fallback[s] then
      return false
    end
  end
  ---@param mode 'normal'|'insert'|'visual'|'command'
  ---@param section 'a'|'b'|'c'
  ---@return vim.api.keyset.hl_info
  local function palget(mode, section)
    if palette[mode] and palette[mode][section] then
      return palette[mode][section]
    end
    return fallback[section]
  end

  local hls = {
    ['St_normal'] = { fg = palget('normal', 'c').fg, palget('normal', 'c').fg },
  }
  local modes = {
    ['St_NormalMode'] = palget('normal', 'a'),
    ['St_VisualMode'] = palget('visual', 'a'),
    ['St_InsertMode'] = palget('insert', 'a'),
    ['St_ReplaceMode'] = { link = 'St_InsertMode' },
    ['St_SelectMode'] = { link = 'St_VisualMode' },
    ['St_CommandMode'] = palget('command', 'a'),
    ['St_TerminalMode'] = { link = 'St_NormalMode' },
    ['St_NTerminalMode'] = { link = 'St_TerminalMode' },
    ['St_ConfirmMode'] = { link = 'St_CommandMode' },
  }
  hls = vim.tbl_deep_extend('force', hls, modes)

  local sections = {
    ['St_section_b'] = palget('normal', 'b'),
    ['St_section_c'] = palget('normal', 'c'),
    ['St_section_m'] = palget('normal', 'c'),
    ['St_section_x'] = palget('normal', 'c'),
    ['St_section_y'] = palget('normal', 'b'),
  }
  hls = vim.tbl_deep_extend('force', hls, sections)
  local sections_sep = {
    ['St_section_b_sep'] = { fg = sections['St_section_b'].bg, bg = sections['St_section_c'].bg },
    ['St_section_y_sep'] = { fg = sections['St_section_y'].bg, bg = sections['St_section_x'].bg },
  }
  hls = vim.tbl_deep_extend('force', hls, sections_sep)

  local modes_sep = {
    ['St_NormalModeSep'] = { fg = modes['St_NormalMode'].bg, bg = sections['St_section_b'].bg },
    ['St_VisualModeSep'] = { fg = modes['St_VisualMode'].bg, bg = sections['St_section_b'].bg },
    ['St_InsertModeSep'] = { fg = modes['St_InsertMode'].bg, bg = sections['St_section_b'].bg },
    ['St_ReplaceModeSep'] = { link = 'St_InsertModeSep' },
    ['St_SelectModeSep'] = { link = 'St_VisualModeSep' },
    ['St_CommandModeSep'] = { link = 'St_NormalModeSep' },
    ['St_TerminalModeSep'] = { link = 'St_NormalModeSep' },
    ['St_NTerminalModeSep'] = { link = 'St_TerminalModeSep' },
    ['St_ConfirmModeSep'] = { link = 'St_CommandModeSep' },
  }
  hls = vim.tbl_deep_extend('force', hls, modes_sep)

  core.lib.hl.apply(hls)

  return true
end

M.apply_highlights = function()
  local scheme_name = core.config.ui.colorscheme
  local ok, palette = pcall(require, ('lualine.themes.%s'):format(scheme_name))
  if not ok then
    local normal_bg = core.lib.hl:get('ui', 'bg')
    local normal_fg = core.lib.hl:get('ui', 'fg')

    local accent_bg = core.lib.hl:get('ui', 'border')
    local comment_fg = core.lib.hl:get('ui', 'comment')
    palette = {
      normal = {
        a = { fg = normal_bg, bg = core.lib.hl:get('ui', 'accent') },
        b = { fg = normal_fg, bg = accent_bg },
        c = { fg = comment_fg, bg = core.lib.hl:get('ui', 'bg_accent') },
      },
      insert = {
        a = { fg = normal_bg, bg = core.lib.hl:get('ui', 'focus') },
      },
      visual = {
        a = { fg = normal_bg, bg = core.lib.hl:get('syntax', 'constant') },
      },
    }
  end
  apply_palette(palette)
end

return M
