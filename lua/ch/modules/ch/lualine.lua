return {
  default = {
    opts = {
      ---@type chLualineOpts__options
      options = {
        separators = nil,
      },
      ---@type LualineConfig
      config = {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = true,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = { { 'mode', fmt = function(str) return str:sub(1, 1) end } },
          lualine_b = {
            'branch',
            function() return CUTIL.PATH_DIR {} end,
            'diff',
            {
              'diagnostics',
              symbols =
              {
                error = ch.lib.icons.diagnostic.error,
                warn = ch.lib.icons.diagnostic.warn,
                info = ch.lib.icons.diagnostic.info,
                hint = ch.lib.icons.diagnostic.hint
              }
            }
          },
          lualine_c = { 'filename' },
          lualine_x = { 'filetype' },
          lualine_y = { function() return CUTIL.FILE_INFO {} end },
          lualine_z = { function()
            local row, column = unpack(vim.api.nvim_win_get_cursor(0))
            return "L" .. row .. ":" .. column
          end }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { function() return vim.fn.expand('%l:%L') end },
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},

        winbar = {},
        inactive_winbar = {},

        extensions = {}
      },
    },
  },
  overwrite = {
    reload = false,
  },
}
