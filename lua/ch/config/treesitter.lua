local ensure = { 'markdown', 'markdown_inline', 'vimdoc' }

return {
  module = {
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
  },
  setup = function(opts)
    ch.log('treesitter.setup', 'loading treesitter.')
    require('ch.plugins').load 'treesitter'

    local ok, treesitter = SR_L 'nvim-treesitter'
    if not ok then
      return
    end
    treesitter.setup()

    if
      type(opts.ensure_installed) == 'string'
      and opts.ensure_installed ~= 'all'
    then
      opts.ensure_installed = { opts.ensure_installed }
    end
    if type(opts.ensure_installed) == 'table' then
      vim.iter(ipairs(ensure)):each(function(_, v)
        ---@diagnostic disable-next-line: assign-type-mismatch
        opts.ensure_installed[#opts.ensure_installed + 1] = v
      end)
    end
    opts.config.ensure_installed = opts.ensure_installed
    require('nvim-treesitter.configs').setup(opts.config)

    keymaps.normal['gm'] =
      { vim.show_pos, 'Show TS highlight groups under cursor' }
  end,
}
