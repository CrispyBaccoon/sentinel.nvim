return {
  default = {
    opts = {
      ---@type TSConfig
      config = {
        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,
        -- Automatically install missing parsers when entering buffer
        auto_install = true,
        -- List of parsers to ignore installing (for "all")
        ignore_install = {},
        highlight = {
          enable = true,
          disable = {},
          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
        textobjects = {},
        indent = { enable = true },
        ensure_installed = {}, -- configure with opts.ensure_installed
        modules = {},
      },
      ensure_installed = {},
    },
  },
}
