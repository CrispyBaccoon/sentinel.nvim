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
    url = 'crispybaccoon/keymaps.nvim',
    opts = {},
  },
  plenary = Util.create_bootstrap {
    name = 'plenary',
    url = 'nvim-lua/plenary.nvim',
  },
  telescope = Util.create_bootstrap {
    name = 'telescope',
    url = 'nvim-telescope/telescope.nvim',
  },
  lualine = Util.create_bootstrap {
    name = 'lualine',
    url = 'nvim-lualine/lualine.nvim',
  },
  evergarden = Util.create_bootstrap {
    name = 'evergarden',
    url = 'crispybaccoon/evergarden',
  },
  lazy = Util.create_bootstrap {
    name = 'lazy',
    url = 'folke/lazy.nvim',
    dir = 'lazy.nvim',
    mod = 'lazy',
  },
}

---@param name string
---@param props string
---@return function|nil
local function _get(name, props)
  local _fn = fn[name]
  if not _fn or not _fn[props] then
    Util.log('bootstrap function ' .. props .. ' not found for: ' .. name, 'error')
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
