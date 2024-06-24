return {
  default = {
    --- default mappings can be disabled with:
    --- ```lua
    --- opts = {
    ---   mappings = {
    ---     normal = {},
    ---     visual = {},
    ---     insert = {},
    ---   },
    --- },
    --- ```
    opts = {
      leader = 'SPC',
      -- localleader is appended to leader
      -- ```lua
      -- {
      --   leader = 'SPC', -> 'SPC'
      --   localleader = 'm', -> 'SPC + m'
      -- }
      -- ```
      localleader = 'm',
      -- default options used for keymaps
      defaults = {},
      -- special keys are imported from ui->key_labels
      special_keys = nil,
      mappings = {
        file = {
          { 'normal', '<c-s>', vim.cmd.update, 'save file' },
        },
        movement = {
          { 'normal', 'W', 'g_', 'goto last non empty of line' },
          { 'normal', 'B', '^', 'goto first non empty of line' },
          { 'visual', 'W', 'g_', 'goto last non empty of line' },
          { 'visual', 'B', '^', 'goto first non empty of line' },
        },
        tabs = {
          -- tab switching
          { 'normal', '<space><tab>]', vim.cmd.tabnext, 'next tab' },
          { 'normal', '<space><tab>[', vim.cmd.tabprev, 'prev tab' },
          { 'normal', '<space><tab>n', ':$tabedit<CR>', 'open new tab' },
          { 'normal', '<space><tab>d', ':tabclose<CR>', 'close current tab' },
          { 'normal', '<space><tab>x', ':tabclose<CR>', 'close current tab' },
          {
            'normal',
            '<space><tab><',
            function()
              vim.cmd [[ -tabmove ]]
            end,
            'move tab to the left',
          },
          {
            'normal',
            '<space><tab>>',
            function()
              vim.cmd [[ +tabmove ]]
            end,
            'move tab to the right',
          },
        },
        windows = {
          {
            'normal',
            '<C-\\>',
            ':vs<CR>:wincmd l<CR>',
            'split file vertically',
          },
          { 'normal', '<C-h>', '<C-w>h', 'switch window left' },
          { 'normal', '<C-l>', '<C-w>l', 'switch window right' },
          { 'normal', '<C-j>', '<C-w>j', 'switch window down' },
          { 'normal', '<C-k>', '<C-w>k', 'switch window up' },
        },
        buffers = {
          { 'normal', '<leader>x', ':Close<cr>', 'close buffer' },
        },
        qf_list = {
          -- quick fix list
          { 'normal', '<c-n>', ':cnext<cr>', 'goto next item in qf list' },
          { 'normal', '<c-b>', ':cprev<cr>', 'goto prev item in qf list' },
          {
            'normal',
            '<leader>q',
            function()
              local items = ch.lib.options:get('keymaps', 'qf_loaders')
              vim.ui.select(vim.tbl_keys(items), {}, function(item)
                if not item then
                  return
                end
                local fn = items[item]
                if fn and type(fn) == 'function' then
                  fn()
                end
              end)
            end,
            'load qf list items',
          },
          {
            'normal',
            '<leader>sq',
            function()
              ch.lib.keymaps.open_qf_list()
            end,
            'open qf list',
          },
        },
        indent = {
          -- < and > indents
          { 'visual', '<', '<gv', 'decrease indention' },
          { 'visual', '>', '>gv', 'increase indention' },
        },
        toggle_ui = {
          {
            'normal',
            ',tb',
            function()
              ---@diagnostic disable
              _G.toggle_transparent_background()
            end,
            'toggle transparent background',
          },
        },
        show_ui = {
          {
            'normal',
            '<leader>sc',
            function()
              require('ch.ui.cheatsheet').open()
            end,
            'show cheatsheet',
          },
          {
            'normal',
            '<leader>sh',
            function()
              require('ch.ui.status'):open()
            end,
            'show ch status',
          },
          {
            'normal',
            '<leader>sll',
            function()
              require('lazy').home()
            end,
            'show lazy',
          },
        },
        copy_paste = {
          -- copy/pasting from system clipboard
          { 'normal', '<c-v>', '"+p', 'paste from system clipboard' },
          { 'visual', '<c-c>', '"+y', 'copy to system clipboard' },
        },
        selection = {
          { 'normal', '<M-v>', '^vg_', 'select contents of current line' },
          { 'normal', '<C-d>', 'viw', 'select current word' },
        },
        comments = {
          { 'normal', 'gcu', 'yyp^wv$hr-', 'underline comment' },
        },
        fixup = {
          { 'normal', '<S-up>', '<nop>', 'disable shift movement' },
          { 'normal', '<S-down>', '<nop>', 'disable shift movement' },
        },
      },
      qf_loaders = {},
    },
  },
}
