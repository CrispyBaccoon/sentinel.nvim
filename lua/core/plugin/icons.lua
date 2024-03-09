---@alias Icons { [string]: string }

---@class CoreIcons
---@field syntax Icons
---@field item Icons
---@field info Icons
---@field diff Icons
---@field diff_status Icons
---@field diagnostic Icons
---@field ui Icons
---@field separator Icons
---@field git Icons
---@field debug Icons

return {
  ---@return CoreIcons
  create = function()
    return {
      syntax = {
        text          = '',
        method        = '',
        fn            = '',
        constructor   = '',
        field         = 'ﰠ',
        variable      = '󰀫',
        class         = 'ﴯ',
        interface     = '',
        module        = '',
        property      = 'ﰠ',
        unit          = '',
        value         = '',
        enum          = '',
        keyword       = '',
        snippet       = '',
        color         = '',
        file          = '',
        reference     = '',
        folder        = '',
        enummember    = '',
        constant      = '',
        struct        = 'פּ',
        event         = '',
        operator      = '',
        typeparameter = '',
        namespace     = '󰌗',
        table         = '',
        object        = '󰅩',
        tag           = '',
        array         = '[]',
        boolean       = '',
        number        = '',
        null          = '󰟢',
        string        = '＂',
        package       = '',
      },
      item = {
        colors = '󰏘',
        find = '',
      },
      info = {
        loaded = "●",
        not_loaded = "○",
        fold_open = '',
        fold_closed = '',
      },
      diff = {
        added = '󰐖',
        changed = '󰦓',
        deleted = '󰍵',
      },
      diff_status = {
        added = '',
        changed = '',
        deleted = '',
      },
      diagnostic = {
        error = '󰅙',
        warn = '',
        info = '󰋼',
        hint = '󰌵',
      },
      ui = {
        item_prefix = '',
        dot = '·',
      },
      separator = {
        slant = { left = "", right = "" },
        round = { left = "", right = "" },
        block = { left = "█", right = "█" },
        arrow = { left = "", right = "" },
      },
      git = {
        branch = '',
      },
      debug = {
        start = '',
        pause = '',
        continue = '',
        restart = '',
        step_into = '',
        step_out = '',
        step_over = '',
        step_back = '',
        stop = '',
        data = '',
        log = '',
      },
    }
  end,
  setup = function()
    core.lib.icons = require 'core.plugin.icons'.create()

    -- [FIXME]
    ---@deprecated
    core.icons = require 'core.plugin.icons'.create()
  end,
}
