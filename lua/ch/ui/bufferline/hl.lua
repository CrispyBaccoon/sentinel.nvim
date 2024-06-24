local M = {}

M.setup_highlights = function()
  ch.lib.autocmd.create {
    event = 'ColorScheme', priority = GC.priority.handle.colorscheme.plugin,
    desc = 'apply bufferline hls',
    fn = function(_)
      require 'ch.ui.bufferline.hl'.apply_highlights()
    end
  }
end

M.apply_highlights = function()
  local normal_bg = ch.lib.hl:get('ui', 'bg')
  local normal_fg = ch.lib.hl:get('ui', 'fg')

  local comment_fg = ch.lib.hl:get('ui', 'comment')

  local title_fg = ch.lib.hl:get('syntax', 'title')

  local hls = {
    ['BfLineFill'] = { fg = title_fg },
    ['BfKillBuf'] = { fg = title_fg },
    ['BfLineBufOn'] = { fg = normal_fg },
    ['BfLineBufOff'] = { fg = comment_fg },
    ['BfLineBufOnModified'] = { fg = normal_fg },
    ['BfLineBufOffModified'] = { fg = comment_fg },
    ['BfLineBufOnClose'] = { fg = ch.lib.hl:get('diagnostic', 'error') },
    ['BfLineBufOffClose'] = { link = 'BfLineBufOff' },
    ['BfLineTabOn'] = { fg = normal_bg, bg = ch.lib.hl:get('ui', 'accent') },
    ['BfLineTabOff'] = { fg = title_fg },
    ['BfLineTabCloseBtn'] = { link = 'BfLineTabOn' },
    ['BfLineTabNewBtn'] = { link = 'BfTabTitle' },
    ['BfTabTitle'] = { fg = normal_fg, bg = normal_bg },
    ['BfTabTitleSep'] = { fg = normal_bg },
    ['BfLineCloseAllBufsBtn'] = { link = 'BfTabTitle' },
  }
  local modes = {
  }
  hls = vim.tbl_deep_extend('force', hls, modes)

  ch.lib.hl.apply(hls)
end

return M
