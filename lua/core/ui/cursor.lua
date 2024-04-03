return {
  setcursor = function(_, mode)
    local hls = require 'core.ui.cursor'.create()
    if not hls or not hls.hl or not hls.hl[mode] then return end

    core.lib.hl.apply({ CursorLine = hls.hl[mode] })
  end,
  setup = function()
    vim.opt.cursorline = true
    vim.opt.guicursor = 'n-v-c-sm:block-NCursor,i-ci-ve:ver25-ICursor,r-cr-o:hor20-RCursor'
    local hls = require 'core.ui.cursor'.create()
    if not hls or not hls.cursor then return end
    core.lib.hl.apply(hls.cursor)

    require 'core.ui.cursor'.setcursor 'normal'
    core.lib.autocmd.create {
      event = 'InsertEnter', priority = 2,
      desc = 'set insert mode cursor hl',
      fn = function(ev)
        require 'core.ui.cursor'.setcursor (ev.buf, 'insert')
      end
    }
    core.lib.autocmd.create {
      event = 'InsertLeave', priority = 2,
      desc = 'set normal mode cursor hl',
      fn = function(ev)
        require 'core.ui.cursor'.setcursor (ev.buf, 'normal')
      end
    }
  end,
  create = function()
    local normal = core.lib.hl:get('ui', 'bg')
    local cursor = core.lib.hl:get('ui', 'fg')

    local main = core.lib.hl:get('ui', 'current')

    local accent = core.lib.hl:get('ui', 'accent')
    local line = core.lib.hl:get('syntax', 'string')

    -- overlay on bg
    local vibrant = core.lib.color.color_overlay(0.07, { normal, line })
    -- brighten
    vibrant = core.lib.color.hsl_mix({ lum = 0.07 }, { vibrant, core.lib.color.rgb{ r = 200, g = 200, b = 200 } })
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
