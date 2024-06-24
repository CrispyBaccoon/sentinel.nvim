return {
  default = {
    opts = {
      cursor = {
        enabled = true,
      },
      statusline = {
        enabled = true,
      },
      bufferline = {
        enabled = true,
        -- add numbers to each tab in bufferline
        show_numbers = true,
        -- callback fn to modify bufferline modules
        overriden_modules = nil,
      },
      ---@class ch.types.ui.term.config
      terminal = {
        enabled = true,
        mappings = {
          open_float = '<c-x>tt',
          open_vertical = '<c-x>tv',
          open_horizontal = '<c-x>th',
        },
        ui = {
          float = {
            relative = 'editor',
            -- row = 0.3,
            -- col = 0.25,
            width = 0.64,
            height = 0.64,
          },
          horizontal = { location = 'rightbelow', split_ratio = 0.3 },
          vertical = { location = 'rightbelow', split_ratio = 0.5 },
        },
        behavior = {
          autoclose_on_quit = {
            enabled = false,
            confirm = true,
          },
          close_on_exit = true,
          auto_insert = true,
        },
        terminals = {
          list = {},
        },
      },
      input = {
        -- Set to false to disable the vim.ui.input implementation
        enabled = true,

        -- Default prompt string
        default_prompt = '',

        -- Can be 'left', 'right', or 'center'
        title_pos = 'left',

        -- When true, <Esc> will close the modal
        insert_only = true,

        -- When true, input will start in insert mode.
        start_in_insert = true,

        -- These are passed to nvim_open_win
        border = 'rounded',
        -- 'editor' and 'win' will default to being centered
        relative = 'cursor',

        -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        prefer_width = 40,
        width = nil,
        -- min_width and max_width can be a list of mixed types.
        -- min_width = {20, 0.2} means 'the greater of 20 columns or 20% of total'
        max_width = { 140, 0.9 },
        min_width = { 20, 0.2 },

        buf_options = {},
        win_options = {
          -- Disable line wrapping
          wrap = false,
          -- Indicator for when text exceeds window
          list = true,
          listchars = 'precedes:…,extends:…',
          -- Increase this for more context when text scrolls off the window
          sidescrolloff = 0,
        },

        -- Set to `false` to disable
        mappings = {
          n = {
            close = '<esc>',
            confirm = '<cr>',
          },
          i = {
            close = '<c-c>',
            confirm = '<cr>',
          },
        },

        override = function(conf)
          -- This is the config that will be passed to nvim_open_win.
          -- Change values here to customize the layout
          return conf
        end,
      },
    },
  },
}
