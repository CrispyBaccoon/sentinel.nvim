return {
  ch = {
    {
      'options',
      opts = {
        cursorline = false,
        tab_width = 2,
        scrolloff = 5,
      },
    },
    {
      'ui',
      opts = {
        -- disable cursorline mode highlight
        cursor = {
          enabled = false,
        },
        statusline = {
          enabled = true,
        },
        bufferline = {
          enabled = true,
        },
      }
    },
    {
      'dash',
      opts = {
        open_on_startup = true,
      },
    },
  },
  custom = {
    -- your custom modules (in `lua/custom/`)
    -- {
    --   'example',
    --   opts = {
    --     msg = 'hello from `lua/custom/example`',
    --   },
    -- },
  },
}
