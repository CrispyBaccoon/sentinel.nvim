local opts_table = {
  bottom = {
    notification = {
      view = {
        stack_upwards = true,
      },
      window = {
        align = 'bottom',
      },
    },
  },
  top = {
    notification = {
      view = {
        stack_upwards = false,
      },
      window = {
        align = 'top',
      },
    },
  },
}

return {
  module = {
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
  },
  setup = function(opts)
    ch.log('fidget.setup', 'loading fidget.')
    require('ch.plugins').load 'fidget'

    local ok, fidget = SR_L 'fidget'
    if not ok then
      return
    end
    local additional_opts = opts_table[opts.ui.position]
    opts.config = vim.tbl_deep_extend('force', opts.config, additional_opts)

    fidget.setup(opts.config)
  end,
}
