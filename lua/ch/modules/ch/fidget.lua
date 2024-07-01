return {
  default = {
    opts = {
      ui = {
        position = 'bottom',
      },
      config = {
        progress = {
          display = {
            done_icon = '',
            done_style = '@constant',
          },
        },
        notification = {
          override_vim_notify = true,
          filter = vim.log.levels.DEBUG,
          configs = {
            default = {
              name = 'Notifications',
              icon = '',
              ttl = 4,
              group_style = 'Title',
              icon_style = 'Special',
              annote_style = 'Question',
              debug_style = 'Comment',
              info_style = 'Question',
              warn_style = 'WarningMsg',
              error_style = 'ErrorMsg',
              debug_annote = 'DEBUG',
              info_annote = 'INFO',
              warn_annote = 'WARN',
              error_annote = 'ERROR',
            },
          },
          view = {
            stack_upwards = true,
            group_separator_hl = 'NonText',
          },
          window = {
            normal_hl = 'NonText',
            winblend = 0,
            align = 'bottom',
          },
        },
      },
    },
  },
}
