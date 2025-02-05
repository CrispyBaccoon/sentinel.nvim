return {
  module = {
    default = {
      opts = {
        mappings = {
          -- jump in dynamic snippets
          jump_next = '<m-l>',
          jump_prev = '<m-h>',
          -- choose item in choice node
          choose_next = '<c-j>',
          choose_prev = '<c-k>',
        },
        config = {
          -- This tells LuaSnip to remember to keep around the last snippet.
          -- You can jump back into it even if you move outside of the selection
          history = true,
          updateevents = 'InsertLeave',
          enable_autosnippets = false,
          ext_opts = nil,
        },
        -- can import a table of languages; set to true to import all
        -- import_languages = { 'rust', 'go', 'lua', 'c', 'cpp', 'html', 'js', 'bash' },
        import_languages = true,
      },
    },
  },
  setup = function(opts)
    ch.log('luasnip.setup', 'loading luasnip.')
    require 'ch.plugins'.load 'luasnip'

    local ok, _ = SR_L 'luasnip'
    if not ok then
      return
    end
    local plugins = {
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    }
    require('ch.plugins').load_plugins(plugins)

    require 'luasnip'.config.set_config(opts.config)

    -- load snippets from snippets directory
    local snippets_opts = {
        paths = ('%s/%s'):format(ch.path.lazy, 'friendly-snippets'),
    }
    if opts.import_languages and type(opts.import_languages) == 'table' then
      snippets_opts.include = opts.import_languages
    end
    require 'luasnip.loaders.from_vscode'.lazy_load(snippets_opts)

    -- this will expand the current item or jump to the next item within the snippet.
    vim.keymap.set({ 'i', 's' }, opts.mappings.jump_next, function()
      if require 'luasnip'.expand_or_jumpable() then
        require 'luasnip'.expand_or_jump()
      end
    end, { silent = true, desc = '[luasnip] expand or jump' })

    -- <c-h> is the jump backwards key.
    -- this always moves to the previous item within the snippet
    vim.keymap.set({ 'i', 's' }, opts.mappings.jump_prev, function()
      if require 'luasnip'.jumpable(-1) then
        require 'luasnip'.jump(-1)
      end
    end, { silent = true, desc = '[luasnip] jump backwards' })

    -- <c-j> selects the next item within a list of options.
    -- This is useful for choice nodes
    vim.keymap.set('i', opts.mappings.choose_next, function()
      if require 'luasnip'.choice_active() then
        require 'luasnip'.change_choice(1)
      end
    end, { desc = '[luasnip] choose next' })
    -- <c-k> selects the previous item within a list of options.
    vim.keymap.set('i', opts.mappings.choose_prev, function()
      if require 'luasnip'.choice_active() then
        require 'luasnip'.change_choice(-1)
      end
    end, { desc = '[luasnip] choose previous' })
  end,
}
