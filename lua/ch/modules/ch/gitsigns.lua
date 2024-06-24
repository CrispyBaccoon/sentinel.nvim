return {
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
}
