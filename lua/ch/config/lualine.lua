---@alias fmt_f fun(str: string): string
---@alias wrapper_f fun(): string
---@alias separator { left: string, right: string }|string
---
---@class LualineConfig__component
---@field [1] string
---@field fmt? fmt_f
---@field icon? string
---@field separator? separator
---@field cond? function
---@field draw_empty? boolean
---@field color? any
---@field type? any
---@field padding? integer
---@field on_click? function

---@class LualineConfig__options
---@field icons_enabled? boolean
---@field theme? 'auto'|string
---@field component_separators? separator
---@field section_separators? separator
---@field always_divide_middle? boolean
---@field globalstatus? boolean
---@field refresh? { ['statusline'|'tabline'|'winbar']: integer }
---@class LualineConfig__sections
---@field lualine_a? LualineConfig__section
---@field lualine_b? LualineConfig__section
---@field lualine_c? LualineConfig__section
---@field lualine_x? LualineConfig__section
---@field lualine_y? LualineConfig__section
---@field lualine_z? LualineConfig__section
---@alias LualineConfig__section (LualineConfig__component|wrapper_f|string)[]

---@class LualineConfig
---@field options? LualineConfig__options
---@field sections? LualineConfig__sections
---@field inactive_sections? LualineConfig__sections

---@alias LualineStyle 'minimal'

---@type { [LualineStyle]: LualineConfig }
local styles = {
  minimal = {
    options = {
      component_separators = '',
      section_separators = '',
    }
  }
}

---@class chLualineOpts__options
---@field separators? 'slant'|'round'|'block'|'arrow'

---@class chLualineOpts
---@field options chLualineOpts__options
---@field config LualineConfig
---@field style? LualineStyle

return {
  module = {
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
  },
  ---@param opts chLualineOpts
  setup = function(opts)
    ch.log('lualine.setup', 'loading lualine.')
    require 'ch.plugins'.load 'lualine'

    local ok, lualine = SR_L 'lualine'
    if not ok then
      return
    end

    local config = opts.config

    if not opts.options.separators then
      opts.options.separators = ch.config.ui.separator_style
    end

    if opts.options.separators and ch.lib.icons.separator[opts.options.separators] then
      config = vim.tbl_deep_extend('force', config, styles.minimal)

      local sep = ch.lib.icons.separator[opts.options.separators]
      config.options.section_separators = { left = sep.right, right = sep.left }
    end

    if opts.style and styles[opts.style] then
      config = vim.tbl_deep_extend('force', config, styles[opts.style])
    end

    lualine.setup(config)
  end
}
