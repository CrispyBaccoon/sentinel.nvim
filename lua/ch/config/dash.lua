return {
  module = {
    default = {
      opts = {
        open_on_startup = true,
        header = {
          [[]],
          [[   ／l、      ]],
          [[ （ﾟ､ ｡ ７    ]],
          [[   l  ~ヽ     ]],
          [[   じしf_,)ノ ]],
          [[]],
        },
        buttons = function()
          local buttons = {
            ch.modules.ch.telescope.opts.mappings.find_files,
            ch.modules.ch.telescope.opts.mappings.colorscheme,
          }

          local result = {}

          vim.iter(ipairs(buttons)):each(function(i, lhs)
            local map = require 'keymaps.data'.get_mapping({ lhs = lhs }) or { desc = '', lhs = '', rhs = print }
            result[i] = { map.desc, map.lhs, map.rhs }
          end)

          local map = require 'keymaps.data'.get_mapping({ desc = 'show cheatsheet' }) or { desc = '', lhs = '', rhs = print }
          result[#result + 1] = { map.desc, map.lhs, map.rhs }
          return result
        end,
      },
    },
  },
  setup = function(opts)
    require 'ch.plugin.command'.create {
      name = 'Dash', fn = function(_)
        require 'ch.plugin.dash'.open(ch.modules.ch.dash.opts)
      end,
    }
    if opts.open_on_startup then
      vim.defer_fn(function()
        local buf_lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)
        local no_buf_content = vim.api.nvim_buf_line_count(0) == 1 and buf_lines[1] == ""
        local bufname = vim.api.nvim_buf_get_name(0)

        if bufname == "" and no_buf_content then
          require 'ch.plugin.dash'.open(opts)
        end
      end, 0)
    end
  end
}
