local Util = require 'core.utils'

---@type { [string]: { boot: function, load: function, update: function }|nil }
local fn = {
  core = {
    update = function()
      Util.git_pull {
        name = 'core',
        path = core.path.core,
      }
    end,
  },
  keymaps = Util.create_bootstrap {
    name = 'keymaps',
    url = 'comfysage/keymaps.nvim',
    dir = 'keymaps.nvim',
    opts = {},
  },
  base46 = Util.create_bootstrap {
    name = 'base46',
    url = 'comfysage/base46',
    opts = false,
  },
  plenary = Util.create_bootstrap {
    name = 'plenary',
    url = 'nvim-lua/plenary.nvim',
    dir = 'plenary.nvim',
  },
  telescope = Util.create_bootstrap {
    name = 'telescope',
    url = 'nvim-telescope/telescope.nvim',
    dir = 'telescope.nvim',
  },
  lualine = Util.create_bootstrap {
    name = 'lualine',
    url = 'nvim-lualine/lualine.nvim',
    dir = 'lualine.nvim',
  },
  evergarden = Util.create_bootstrap {
    name = 'evergarden',
    url = 'comfysage/evergarden',
  },
  lazyplug = Util.create_bootstrap {
    name = 'lazyplug',
    url = 'folke/lazy.nvim',
    dir = 'lazy.nvim',
    mod = 'lazy',
  },
  treesitter = Util.create_bootstrap {
    name = 'treesitter',
    url = 'nvim-treesitter/nvim-treesitter',
    mod = 'nvim-treesitter',
    dir = 'nvim-treesitter',
  },
  cmp = Util.create_bootstrap {
    name = 'cmp',
    url = 'hrsh7th/nvim-cmp',
    dir = 'nvim-cmp',
  },
  lspconfig = Util.create_bootstrap {
    name = 'lspconfig',
    url = 'neovim/nvim-lspconfig',
    dir = 'nvim-lspconfig',
  },
  luasnip = Util.create_bootstrap {
    name = 'luasnip',
    url = 'L3MON4D3/LuaSnip',
  },
  null = Util.create_bootstrap {
    name = 'null-ls',
    url = 'nvimtools/none-ls.nvim',
    dir = 'none-ls.nvim',
  },
  mini = Util.create_bootstrap {
    name = 'mini',
    url = 'echasnovski/mini.nvim',
    dir = 'mini.nvim',
    opts = false,
  },
  gitsigns = Util.create_bootstrap {
    name = 'gitsigns',
    url = 'lewis6991/gitsigns.nvim',
    dir = 'gitsigns.nvim',
  },
  telescope_fzf = Util.create_bootstrap {
    name = 'telescope_fzf',
    url = 'nvim-telescope/telescope-fzf-native.nvim',
    dir = 'telescope-fzf-native.nvim',
    opts = false,
  },
  telescope_select = Util.create_bootstrap {
    name = 'telescope_select',
    url = 'nvim-telescope/telescope-ui-select.nvim',
    dir = 'telescope-ui-select.nvim',
    opts = false,
  },
  whichkey = Util.create_bootstrap {
    name = 'whichkey',
    url = 'folke/which-key.nvim',
    dir = 'which-key.nvim',
    opts = false,
  },
  todo_comments = Util.create_bootstrap {
    name = 'todo_comments',
    url = 'folke/todo-comments.nvim',
    dir = 'todo-comments.nvim',
    opts = false,
  },
  trouble = Util.create_bootstrap {
    name = 'trouble',
    url = 'folke/trouble.nvim',
    dir = 'trouble.nvim',
    opts = false,
  },
  incline = Util.create_bootstrap {
    name = 'incline',
    url = 'b0o/incline.nvim',
    dir = 'incline.nvim',
    opts = false,
  },
}

---@param name string
---@param props string
---@return function|nil
local function _get(name, props)
  local _fn = fn[name]
  if not _fn or not _fn[props] then
    Util.log('core.bootstrap', 'bootstrap function ' .. props .. ' not found for: ' .. name, 'error')
    return
  end
  return _fn[props]
end

return {
  boot = function(props)
    local _fn = _get(props, 'boot')
    if _fn then
      _fn()
    end
  end,
  load = function(props)
    local _fn = _get(props, 'load')
    if _fn then
      _fn()
    end
  end,
  update = function(props)
    local _fn = _get(props, 'update')
    if _fn then
      _fn()
    end
  end,
}
