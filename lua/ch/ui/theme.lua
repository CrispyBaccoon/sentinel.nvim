return {
  ---@param theme ch.types.lib.hl.table
  ---@param config table
  create = function(theme, config)
    local hl_groups = {
      NormalFloat = { theme.ui.fg, theme.ui.bg_accent },
      FloatTitle = { theme.ui.bg, theme.ui.accent },
      FloatBorder = { theme.ui.border },
      StatusLine = { theme.ui.comment, theme.ui.bg_accent },
      StatusLineNC = { theme.ui.comment, theme.ui.bg_accent },
      FloatShadow = { 'none', 'none' },
      FloatShadowThrough = { 'none', 'none' },

      OkText = { theme.diagnostic.ok, 'none' },
      ErrorText = { theme.diagnostic.error, 'none' },
      WarningText = { theme.diagnostic.warn, 'none' },
      InfoText = { theme.diagnostic.info, 'none' },
      HintText = { theme.diagnostic.hint, 'none' },
      OkFloat = { theme.diagnostic.ok, theme.ui.bg_accent },
      ErrorFloat = { theme.diagnostic.error, theme.ui.bg_accent },
      WarningFloat = { theme.diagnostic.warn, theme.ui.bg_accent },
      InfoFloat = { theme.diagnostic.info, theme.ui.bg_accent },
      HintFloat = { theme.diagnostic.hint, theme.ui.bg_accent },

      Error = { theme.diagnostic.error },
      ErrorMsg = { link = 'Error' },
      WarningMsg = { theme.diagnostic.warn },
      MoreMsg = { theme.ui.comment },
      ModeMsg = { theme.ui.bg2, 'none' },

      Search = { theme.ui.match, reverse = config.search.reverse },
      IncSearch = { theme.ui.focus, reverse = config.inc_search.reverse },

      Todo = { theme.ui.bg, theme.ui.purple },

      -- Completion Menu
      Pmenu = { theme.ui.grey1, theme.ui.bg2 },
      PmenuSel = {
        theme.ui.bg2,
        theme.ui.pmenu_bg,
        reverse = config.search.reverse,
      },
      PmenuSbar = { 'none', theme.ui.bg2 },
      PmenuThumb = { 'none', theme.ui.grey1 },
    }

    hl_groups['@none'] = { theme.ui.fg }
    hl_groups['@none.markdown'] = { 'none', 'none' }

    return hl_groups
  end,
  apply = function()
    ch.log('ch.ui', 'applying theme')
    local theme = ch.lib.hl.__value
    local config = ch.config.ui.theme_config
    local hl_groups = require('ch.ui.theme').create(theme, config)
    ch.log('ch.ui', ('applying "%s" hl groups'):format 'main')
    hl_groups = vim.iter(hl_groups):map(function(v)
      v.default = true
      return v
    end)
    ch.lib.hl.apply(hl_groups)
  end,
}
