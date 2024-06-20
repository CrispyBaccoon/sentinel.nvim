return {
  setup = function(opts)
    require 'core.plugins'.load 'gitsigns'

    local ok, gs = SR_L 'gitsigns'
    if not ok then
      return
    end

    local signs = {
        add          = { hl = 'GitSignsAdd', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
        change       = { hl = 'GitSignsChange', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
        delete       = { hl = 'GitSignsDelete', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
    }
    for k, _ in pairs(signs) do
      local _first = string.sub(k, 1, 1)
      local hl_name = string.format('GitSigns%s%s', _first:upper(), k:sub(2))
      signs[k] = {
        hl     = hl_name,
        numhl  = string.format('%sNr', hl_name),
        linehl = string.format('%sLn', hl_name),
      }
    end
    signs.untracked    = signs.add
    signs.changedelete = signs.change
    signs.topdelete    = signs.delete
    for k, v in pairs(signs) do
      opts.config.signs[k] = vim.tbl_deep_extend('force', opts.config.signs[k], v)
    end
    require 'core.plugin.highlight'.apply {
      GitSignsAdd    = {},
      GitSignsChange = {},
      GitSignsDelete = {},
    }

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
        if vim.wo.diff then return core.modules.core.gitsigns.opts.mappings.next_hunk end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end,
      'jump to the next hunk in the current buffer',
      group = 'git',
      { expr = true }
    }

    keymaps.normal[opts.mappings.prev_hunk] = {
      function()
        if vim.wo.diff then return core.modules.core.gitsigns.opts.mappings.prev_hunk end
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

    core.lib.keymaps.register_qf_loader('git_hunks', function()
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
