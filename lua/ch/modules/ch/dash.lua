return {
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
}
