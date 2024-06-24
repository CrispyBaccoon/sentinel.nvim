local M = {}

M.setup_highlights = function()
  ch.lib.autocmd.create {
    event = 'ColorScheme', priority = GC.priority.handle.colorscheme.plugin,
    desc = 'load statusline hls',
    fn = function(_)
      require 'ch.ui.statusline.hl'.apply_highlights()
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
  local sections = {}
  for _, mode in ipairs({'normal', 'insert', 'visual', 'command'}) do
    for _, section in ipairs({'a','b','c'}) do
      sections['St_'..mode..'_'..section] = palget(mode, section)
    end
    sections['St_'..mode..'_x'] = { link = 'St_' .. mode .. '_c' }
    sections['St_'..mode..'_y'] = { link = 'St_' .. mode .. '_b' }
    sections['St_'..mode..'_z'] = { link = 'St_' .. mode .. '_a' }
  end
  hls = vim.tbl_deep_extend('force', hls, sections)
  local sections_sep = {}
  for _, mode in ipairs({'normal', 'insert', 'visual', 'command'}) do
    sections_sep['St_'..mode..'_a_sep'] = { fg = sections['St_'..mode..'_a'].bg, bg = sections['St_'..mode..'_b'].bg }
    sections_sep['St_'..mode..'_b_sep'] = { fg = sections['St_'..mode..'_b'].bg, bg = sections['St_'..mode..'_c'].bg }
    sections_sep['St_'..mode..'_y_sep'] = { link = 'St_'..mode..'_b_sep' }
    sections_sep['St_'..mode..'_z_sep'] = { link = 'St_'..mode..'_a_sep' }
  end
  hls = vim.tbl_deep_extend('force', hls, sections_sep)

  ch.lib.hl.apply(hls)

  return true
end

M.apply_highlights = function()
  local scheme_name = ch.config.ui.colorscheme
  local ok, palette = pcall(require, ('lualine.themes.%s'):format(scheme_name))
  if not ok then
    local normal_bg = ch.lib.hl:get('ui', 'bg')
    local normal_fg = ch.lib.hl:get('ui', 'fg')

    local accent_bg = ch.lib.hl:get('ui', 'border')
    local comment_fg = ch.lib.hl:get('ui', 'comment')
    palette = {
      normal = {
        a = { fg = normal_bg, bg = ch.lib.hl:get('ui', 'accent') },
        b = { fg = normal_fg, bg = accent_bg },
        c = { fg = comment_fg, bg = ch.lib.hl:get('ui', 'bg_accent') },
      },
      insert = {
        a = { fg = normal_bg, bg = ch.lib.hl:get('ui', 'focus') },
      },
      visual = {
        a = { fg = normal_bg, bg = ch.lib.hl:get('syntax', 'constant') },
      },
    }
  end
  apply_palette(palette)
end

return M
