return {
  module = {
    default = {
      opts = {
        config = {
          -- position of the list can be: bottom, top, left, right
          position = 'bottom',
          -- height of the trouble list when position is top or bottom
          height = 10,
          -- width of the list when position is left or right
          width = 50,
          -- use devicons for filenames
          icons = false,
          -- "workspace_diagnostics", "document_diagnostics", "quickfix",
          -- "lsp_references", "loclist"
          mode = 'workspace_diagnostics',
          -- nil (ALL) or vim.diagnostic.severity.ERROR | WARN | INFO | HINT
          severity = nil,
          -- icon used for open folds
          fold_open = ch.lib.icons.info.fold_open,
          -- icon used for closed folds
          fold_closed = ch.lib.icons.info.fold_closed,
          -- group results by file
          group = true,
          -- add an extra new line on top of the list
          padding = true,
          -- cycle item list when reaching beginning or end of list
          cycle_results = true,
          -- key mappings for actions in the trouble list
          -- map to {} to remove a mapping
          action_keys = {
            -- close the list
            close = 'q',
            -- cancel the preview and get back to your last window / buffer / cursor
            cancel = '<esc>',
            -- manually refresh
            refresh = 'r',
            -- jump to the diagnostic or open / close folds
            jump = { '<cr>', '<tab>', '<2-leftmouse>' },
            -- open buffer in new split
            open_split = { '<c-x>' },
            -- open buffer in new vsplit
            open_vsplit = { '<c-v>' },
            -- open buffer in new tab
            open_tab = { '<c-t>' },
            -- jump to the diagnostic and close the list
            jump_close = { 'o' },
            -- toggle between "workspace" and "document" diagnostics mode
            toggle_mode = 'm',
            -- switch "diagnostics" severity filter level to HINT / INFO / WARN / ERROR
            switch_severity = 's',
            -- toggle auto_preview
            toggle_preview = 'P',
            -- opens a small popup with the full multiline message
            hover = 'K',
            -- preview the diagnostic location
            preview = 'p',
            -- if present, open a URI with more information about the diagnostic error
            open_code_href = ch.lib.options:get('lsp', 'mappings', 'goto_definition'),
            -- close all folds
            close_folds = { 'zM', 'zm' },
            -- open all folds
            open_folds = { 'zR', 'zr' },
            -- toggle fold of current file
            toggle_fold = { 'zA', 'za' },
            -- previous item
            previous = 'k',
            -- next item
            next = 'j',
            -- help menu
            help = 'g?',
          },
          -- render multi-line messages
          multiline = true,
          -- add an indent guide below the fold icons
          indent_lines = true,
          -- window configuration for floating windows. See |nvim_open_win()|.
          win_config = { border = 'single' },
          -- automatically open the list when you have diagnostics
          auto_open = false,
          -- automatically close the list when you have no diagnostics
          auto_close = false,
          -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
          auto_preview = true,
          -- automatically fold a file trouble list at creation
          auto_fold = false,
          -- for the given modes, automatically jump if there is only a single result
          auto_jump = { 'lsp_definitions' },
          -- for the given modes, include the declaration of the current symbol in the results
          include_declaration = {
            'lsp_references',
            'lsp_implementations',
            'lsp_definitions',
          },
          -- icons / text used for a diagnostic
          signs = {
            error = ch.lib.icons.diagnostic.error,
            warning = ch.lib.icons.diagnostic.warn,
            hint = ch.lib.icons.diagnostic.hint,
            information = ch.lib.icons.diagnostic.info,
            other = ch.lib.icons.diagnostic.info,
          },
          -- enabling this will use the signs defined in your lsp client
          use_diagnostic_signs = true,
        },
      },
    },
  },
  setup = function(opts)
    ch.log('trouble.setup', 'loading trouble.')
    require('ch.plugins').load 'trouble'

    local ok, trouble = SR_L 'trouble'
    if not ok then
      return
    end

    opts.config.icons = ch.config.ui.devicons
    trouble.setup(opts.config)

    ch.lib.hl.apply {
      TroubleTextWarning = { link = '@text' },
      TroubleLocation = { link = 'NonText' },
    }
  end,
}
