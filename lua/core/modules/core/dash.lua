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
          core.modules.core.telescope.opts.mappings.find_files,
          core.modules.core.telescope.opts.mappings.colorscheme,
        }

        local result = {}

        for i, lhs in ipairs(buttons) do
          local map = require 'keymaps.data'.get_mapping({ lhs = lhs }) or { desc = '', lhs = '', rhs = print }
          result[i] = { map.desc, map.lhs, map.rhs }
        end

        local map = require 'keymaps.data'.get_mapping({ desc = 'show cheatsheet' }) or { desc = '', lhs = '', rhs = print }
        result[#result + 1] = { map.desc, map.lhs, map.rhs }
        return result
      end,
    },
  },
}
