local M = {}

---@type core.config
M.default_config = {
  log_level = vim.log.levels.INFO,
  ui = {
    colorscheme = 'evergarden', -- or 'habamax' or 'zaibatsu' or 'retrobox'
    transparent_background = false,
    -- separators: slant (, ) round (,) block (█,█) arrow (,)
    separator_style = 'round',
    -- use 'nvim-tree/nvim-web-devicons'
    devicons = true,
    theme_config = {
      keyword = { italic = false },
      types = { italic = false },
      comment = { italic = false },
      search = { reverse = false },
      inc_search = { reverse = true }
    },
    key_labels = {
      -- text keys
      ['<space>'] = 'SPC',
      ['<CR>'] = 'RET',
      ['<BS>'] = 'BS',
      -- tab keys
      ['<Tab>'] = 'TAB',
      ['<S-TAB>'] = 'SHIFT TAB',
      -- leader key
      ['<leader>'] = 'LD',
      -- directional keys
      ['<Up>'] = '↑',
      ['<Left>'] = '←',
      ['<Down>'] = '↓',
      ['<Right>'] = '→',
    },
  },
  modules = {},
}

---@param opts core.config
---@return core.config
function M.setup(opts)
  core.config = vim.tbl_deep_extend('force', M.default_config, opts)
  return core.config
end

return M
