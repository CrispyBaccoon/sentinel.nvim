return {
  default = {
    opts = {
      mappings = {
        -- General
        show_lsp_info = '<space>si',
        -- diagnostics
        open_float = 'L',
        goto_prev = '<M-h>',
        goto_next = '<M-l>',
        -- LSP
        goto_declaration = 'gD',
        goto_definition = 'gd',
        peek_definition = '<space>gd',
        goto_references = 'gR',
        goto_implementation = 'gi',
        show_signature = '<C-k>',
        show_type_definition = 'gT',
        hover = 'K',
        show_code_action = 'gl',
        rename = 'gr',
        format = ',fl',
      },
      signature = {
        enabled = true,
        window = {
          height = 20,
          width = 64,
        },
      },
      -- show diagnostics below lines
      diagnostic_lines = {
        enabled = false,
        -- only show virtual lines for severity
        severity = nil,
        -- only render for current line
        only_current_line = true,
        -- boolean highlight empty space to the left of a diagnostic
        highlight_whole_line = false,
      },
      config = {
        -- options passed to `vim.diagnostic.open_float()`
        -- float = {},
        severity_sort = false,
        -- use signs for diagnostics
        signs = {
          text = require('core.utils').get_diagnostic_signs(),
          priority = GC.priority.signs.lsp,
        },
        -- Use underline for diagnostics
        underline = true,
        -- don't update diagnostics while typing
        update_in_insert = false,
        -- Use virtual text for diagnostics
        virtual_text = {
          -- Only show virtual text for diagnostics matching the given severity
          -- severity = '',
          -- Include the diagnostic source in virtual text. Use "if_many" to
          -- only show sources if there is more than one diagnostic source in
          -- the buffer. Otherwise, any truthy value means to always show the
          -- diagnostic source.
          -- boolean|string
          source = false,
          -- Amount of empty spaces inserted at the beginning of the virtual
          -- text.
          -- number
          spacing = 4,
          -- prepend diagnostic message with prefix. If a function, it must
          -- have the signature (diagnostic, i, total) -> string, where
          -- {diagnostic} is of type |diagnostic-structure|, {i} is the index
          -- of the diagnostic being evaluated, and {total} is the total number
          -- of diagnostics for the line. This can be used to render diagnostic
          -- symbols or error codes.
          -- string|function
          prefix = function(props)
            local icons = require('core.utils').get_diagnostic_signs()
            return icons[props.severity]
          end,
          -- Append diagnostic message with suffix. If a function, it must have
          -- the signature (diagnostic) -> string, where {diagnostic} is of
          -- type |diagnostic-structure|. This can be used to render an LSP
          -- diagnostic error code.
          -- string|function
          -- suffix = '',
          -- A function that takes a diagnostic as input and returns a string.
          -- The return value is the text used to display the diagnostic.
          -- function
          -- format = '',
        },
      },
      servers = {},
    },
  },
}
