return {
  module = {
    default = {
      opts = {
        config = {
          debounce_threshold = {
            falling = 50,
            rising = 10,
          },
          hide = {
            cursorline = true,
            focused_win = false,
            only_win = false,
          },
          highlight = {
            groups = {
              InclineNormal = {
                default = true,
                group = 'NormalFloat',
              },
              InclineNormalNC = {
                default = true,
                group = 'NormalFloat',
              },
            },
          },
          ignore = {
            buftypes = 'special',
            filetypes = {},
            floating_wins = true,
            unlisted_buffers = true,
            wintypes = 'special',
          },
          render = 'basic',
          window = {
            margin = {
              horizontal = 1,
              vertical = 1,
            },
            options = {
              signcolumn = 'no',
              wrap = false,
            },
            padding = 1,
            padding_char = ' ',
            placement = {
              horizontal = 'right',
              vertical = 'top',
            },
            width = 'fit',
            winhighlight = {
              active = {
                EndOfBuffer = 'None',
                Normal = 'InclineNormal',
                Search = 'None',
              },
              inactive = {
                EndOfBuffer = 'None',
                Normal = 'InclineNormalNC',
                Search = 'None',
              },
            },
            zindex = 50,
          },
        },
      },
    },
  },
  setup = function(opts)
    ch.log('incline.setup', 'loading incline.')
    require('ch.plugins').load 'incline'

    local ok, incline = SR_L 'incline'
    if not ok then
      return
    end

    incline.setup(opts.config)
  end,
}
