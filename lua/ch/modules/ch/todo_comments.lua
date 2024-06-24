return {
  default = {
    opts = {
      merge_keywords = false,
      keywords = {
        FIX = {
          icon = '! ', -- icon used for the sign, and in search results
          color = 'warning', -- can be a hex color, or a named color (see below)
          alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = '/ ', color = 'info' },
        NOTE = { icon = '. ', color = 'note', alt = { 'INFO' } },
        WARN = { icon = '! ', color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = {
          icon = '* ',
          color = 'test',
          alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' },
        },
        TEST = {
          icon = '* ',
          color = 'test',
          alt = { 'TESTING', 'PASSED', 'FAILED' },
        },
      },
      -- list of named colors where we try to extract the guifg from the
      -- list of highlight groups or use the hex color if hl not found as a fallback
      colors = {
        default = { '@label', '#AACCFF' },
        error = { '@comment.error', 'DiagnosticError', 'ErrorMsg', '#FFA89A' },
        warning = {
          '@comment.warning',
          'DiagnosticWarn',
          'WarningMsg',
          '#FBBB8B',
        },
        info = { '@comment.todo', 'DiagnosticInfo', '#FFCCAE' },
        note = { '@comment.note', 'DiagnosticHint', '#FFFFAA' },
        test = { '@comment.todo', '@conditional', 'Identifier', '#AACCFF' },
      },
      highlight = {
        pattern = { [[.*<(KEYWORDS)\s*:]] },
      },
      search = {
        command = 'rg',
        args = {
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
        },
        -- regex that will be used to match keywords.
        -- don't replace the (KEYWORDS) placeholder
        pattern = { [[\b(KEYWORDS):]] }, -- ripgrep regex
        -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
      },
    },
  }
}
