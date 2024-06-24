return {
  setcursor = function(_, mode)
    local hls = require 'ch.ui.cursor'.create()
    if not hls or not hls.hl or not hls.hl[mode] then return end

    ch.lib.hl.apply({ CursorLine = hls.hl[mode] })
  end,
  setup = function()
    vim.opt.cursorline = true
    local hls = require 'ch.ui.cursor'.create()
    if not hls or not hls.cursor then return end
    ch.lib.hl.apply(hls.cursor)

    require 'ch.ui.cursor'.setcursor 'normal'
    ch.lib.autocmd.create {
      event = 'InsertEnter', priority = 2,
      desc = 'set insert mode cursor hl',
      fn = function(ev)
        require 'ch.ui.cursor'.setcursor (ev.buf, 'insert')
      end
    }
    ch.lib.autocmd.create {
      event = 'InsertLeave', priority = 2,
      desc = 'set normal mode cursor hl',
      fn = function(ev)
        require 'ch.ui.cursor'.setcursor (ev.buf, 'normal')
      end
    }
  end,
  create = function()
    local normal = ch.lib.hl:get('ui', 'bg')
    local cursor = ch.lib.hl:get('ui', 'fg')

    local main = ch.lib.hl:get('ui', 'current')

    local accent = ch.lib.hl:get('ui', 'accent')
    local line = ch.lib.hl:get('syntax', 'string')

    -- overlay on bg
    local vibrant = ch.lib.color.color_overlay(0.07, { normal, line })
    -- brighten
    vibrant = ch.lib.color.hsl_mix({ lum = 0.07 }, { vibrant, ch.lib.color.rgb{ r = 200, g = 200, b = 200 } })
    return {
      hl = {
        normal = { bg = main },
        insert = { bg = vibrant },
      },
      cursor = {
        NCursor = { bg = cursor },
        ICursor = { bg = accent },
      },
    }
  end,
}
