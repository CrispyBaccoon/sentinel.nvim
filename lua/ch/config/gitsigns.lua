return {
  module = {
    default = {
      opts = {
        mappings = {
          next_hunk = ']c',
          prev_hunk = '[c',
          stage_hunk = ',hs',
          reset_hunk = ',hr',
          stage_buffer = ',hS',
          undo_stage_hunk = ',hu',
          reset_buffer = ',hR',
          preview_hunk = ',hp',
          show_line_blame = ',hb',
          toggle_current_line_blame = '.gb',
          toggle_deleted = '.gd',
          diffthis = ',hd',
          show_diff = ',hD',
          select_hunk = 'ih',
        },
        config = {
          signs = {
            add          = { text = '│' },
            change       = { text = '│' },
            delete       = { text = '│' },
            topdelete    = { text = '‾' },
            changedelete = { text = '~' },
            untracked    = { text = '┆' },
          },
          signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
          numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
          linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
          word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
          watch_gitdir = {
            interval = 1000,
            follow_files = true
          },
          attach_to_untracked = true,
          current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
          current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 500,
            ignore_whitespace = false,
          },
          current_line_blame_formatter = '<summary>, <author_time:%Y-%m-%d> ~ <author>',
          sign_priority    = GC.priority.signs.git,
          update_debounce  = 100,
          status_formatter = nil,   -- Use default
          max_file_length  = 40000, -- Disable if file is longer than this (in lines)
          preview_config = {
            -- Options passed to nvim_open_win
            border = 'rounded',
            style = 'minimal',
            relative = 'cursor',
            row = 0,
            col = 1
          },
          on_attach = function(_)
          end,
        },
      },
    },
  },
  setup = function(opts)
    require 'ch.plugins'.load 'gitsigns'

    local ok, gs = SR_L 'gitsigns'
    if not ok then
      return
    end

    gs.setup(opts.config)

    -- clear staged signs
    local staged = {
      { 'GitSignsStagedAdd', 'GitSignsAdd', },
      { 'GitSignsStagedChange', 'GitSignsChange', },
      { 'GitSignsStagedDelete', 'GitSignsDelete', },
      { 'GitSignsStagedChangedelete', 'GitSignsChangedelete', },
      { 'GitSignsStagedTopdelete', 'GitSignsTopdelete', },
      { 'GitSignsStagedAddNr', 'GitSignsAddNr', },
      { 'GitSignsStagedChangeNr', 'GitSignsChangeNr', },
      { 'GitSignsStagedDeleteNr', 'GitSignsDeleteNr', },
      { 'GitSignsStagedChangedeleteNr', 'GitSignsChangedeleteNr', },
      { 'GitSignsStagedTopdeleteNr', 'GitSignsTopdeleteNr', },
      { 'GitSignsStagedAddLn', 'GitSignsAddLn', },
      { 'GitSignsStagedChangeLn', 'GitSignsChangeLn', },
      { 'GitSignsStagedDeleteLn', 'GitSignsDeleteLn', },
      { 'GitSignsStagedChangedeleteLn', 'GitSignsChangedeleteLn', },
      { 'GitSignsStagedTopdeleteLn', 'GitSignsTopdeleteLn', },
    }
    vim.iter(staged):each(function(v)
      vim.api.nvim_set_hl(0, v[1], {link=v[2]})
    end)

    -- Navigation
    keymaps.normal[opts.mappings.next_hunk] = {
      function()
        if vim.wo.diff then return ch.modules.ch.gitsigns.opts.mappings.next_hunk end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end,
      'jump to the next hunk in the current buffer',
      group = 'git',
      { expr = true }
    }

    keymaps.normal[opts.mappings.prev_hunk] = {
      function()
        if vim.wo.diff then return ch.modules.ch.gitsigns.opts.mappings.prev_hunk end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end,
      'jump to the previous hunk in the current buffer',
      group = 'git',
      { expr = true }
    }

    -- Actions
    Keymap.group {
      group = 'git',
      { 'normal', opts.mappings.stage_hunk, gs.stage_hunk, 'stage current hunk' },
      { 'visual', opts.mappings.stage_hunk, gs.stage_hunk, 'stage current hunk' },
      { 'normal', opts.mappings.reset_hunk, gs.reset_hunk, 'reset the lines of the current hunk' },
      { 'visual', opts.mappings.reset_hunk, gs.reset_hunk, 'reset the lines of the current hunk' },
      { 'normal', opts.mappings.stage_buffer, gs.stage_buffer, 'stage buffer' },
      { 'normal', opts.mappings.undo_stage_hunk, gs.undo_stage_hunk, 'undo last call to stage_hunk()' },
      { 'normal', opts.mappings.reset_buffer, gs.reset_buffer, 'reset the lines of all hunks in the buffer' },
      { 'normal', opts.mappings.preview_hunk, gs.preview_hunk, 'preview hunk' },
      { 'normal', opts.mappings.show_line_blame,
        function() gs.blame_line { full = true } end,
        'run git blame on the current line and show the results',
      },
      { 'normal', opts.mappings.toggle_current_line_blame, gs.toggle_current_line_blame, 'toggle current line blame' },
      { 'normal', opts.mappings.toggle_deleted, gs.toggle_deleted, 'toggle show_deleted' },
      { 'normal', opts.mappings.diffthis, gs.diffthis, 'vimdiff on current file' },
      { 'normal', opts.mappings.show_diff, function() gs.diffthis('~') end, 'vimdiff on current file with base ~' },
    }

    ch.lib.keymaps.register_qf_loader('git_hunks', function()
      gs.setqflist('all', { open = false })
    end, { handle_open = true })

    -- Text object
    Keymap.group {
      group = 'git',
      { 'normal', { 'v', opts.mappings.select_hunk }, ':<C-U>Gitsigns select_hunk<CR>', 'select inside hunk' },
      { 'visual', opts.mappings.select_hunk, ':<C-U>Gitsigns select_hunk<CR>', 'select inside hunk' },
    }
  end,
}
