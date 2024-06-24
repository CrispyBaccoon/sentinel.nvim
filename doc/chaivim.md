# getting started

you can install chaivim using the installer:
```bash
curl -fsSL https://github.com/comfysage/chaivim/raw/mega/utils/installer/install.sh | sh
cvim

```
or you can get started using chaivim with the [starter template](https://github.com/comfysage/chaivim/tree/start):
```bash
git clone --depth 1 -b start https://github.com/comfysage/chaivim.git ~/.config/nvim
nvim
```

# usage

chaivim configuration is usually split into `custom.config` and `custom.modules`.

```lua
-- lua/custom/config.lua
return {
    ui = {
        colorscheme = 'evergarden',
        transparent_background = false,
    },
}

-- lua/custom/modules.lua
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
            'dash',
            opts = {
                open_on_startup = true,
            },
        },
    },
    custom = {
        -- your custom modules (in `lua/custom/`)
    },
}
```

# configuration

ch-config
: ch configuration

ch-config-ui
: ui configuration

```lua
{
    -- chaivim uses evergarden by default
    -- some other cozy alternatives are
    -- - [kanagawa](https://github.com/rebelot/kanagawa.nvim)
    -- - [gruvboxed](https://github.com/comfysage/gruvboxed)
    -- - [iceberg](https://github.com/cocopon/iceberg.vim)
    colorscheme = 'evergarden',
    transparent_background = false,
    -- separators: slant (, ) round (,) block (█,█) arrow (,)
    -- these are used for ui components like the statusline
    separator_style = 'round',
    -- (optionally) use 'nvim-tree/nvim-web-devicons'
    devicons = true,
    -- used by `comfysage/base46`
    theme_config = {
      keyword = { italic = false },
      types = { italic = false },
      comment = { italic = false },
      search = { reverse = false },
      inc_search = { reverse = true }
    },
    -- key labels used by `keymaps.nvim` and some ui components
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
}
```

ch-config-log_level
: Minimum log level

Set to `vim.log.levels.OFF` to disable logging from `chai`, or `vim.log.levels.TRACE`
to enable all logging.

Type: `vim.log.levels` (default: `vim.log.levels.INFO`)

module-spec
: specification for a module

modules.highlights.fix
: specification for ch highlight module

Type: `function` (default: `nil`)
