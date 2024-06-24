return {
  default = {
    opts = {
      snippet_engine = 'luasnip',
      mappings = {
        docs_down = '<C-b>',
        docs_up   = '<C-f>',
        complete  = '<C-space>',
        close     = '<C-e>',
      },
      -- 'tab' or 'enter'
      completion_style = 'tab',
      -- 'evergreen' | 'nyoom'
      menu_style = 'evergreen',
      -- register `ch.plugin.cmp-emoji`
      use_emoji_source = true,
      config = {
        window = {
          completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel",
            col_offset = 0,
            side_padding = 1,
          },
        },
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(_)
          end,
        },
        mapping = {},
        formatting = {},
        -- view = { entries = 'native' },
        experimental = {
          ghost_text = { hl_group = 'NonText' },
        }
      },
    },
  },
}
