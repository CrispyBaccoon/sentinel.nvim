local Util = require 'core.utils'

return {
  add_sources = function()
    local sources = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline'
    }
    require('core.plugins').load_plugins(sources)
  end,
  setup = function(opts)
    vim.g.indentLine_conceallevel = 2
    vim.g.indentLine_concealcursor = "inc"

    require 'core.plugins'.load 'nvim-cmp'

    local ok, cmp = SR_L 'cmp'
    if not ok then
      return
    end

    -- local status, result = pcall(require, 'config.plugin.cmp-emoji')
    -- if not status then
    --   vim.notify('error while loading module:\n\t' .. result, vim.log.levels.ERROR)
    --   return
    -- end

    local snippet_fn = {
      vsnip = function(args) vim.fn["vsnip#anonymous"](args.body) end,
      luasnip = function(args) require('luasnip').lsp_expand(args.body) end,
      snippy = function(args) require('snippy').expand_snippet(args.body) end,
      ultisnips = function(args) vim.fn["UltiSnips#Anon"](args.body) end,
    }
    if snippet_fn[opts.snippet_engine] then
      opts.config.snippet.expand = snippet_fn[opts.snippet_engine]
    end

    ---@diagnostic disable-next-line redefined-local
    local ok, lspkind = SR_L 'core.plugin.lspkind'
    if ok then
      opts.config.formatting = lspkind.create_formatter(opts.menu_style)
    end
    if opts.menu_style == 'nyoom' then
      opts.config.window.completion.col_offset = -3
      opts.config.window.completion.side_padding = 0
    end

    opts.config.sources = {
      { name = 'nvim_lua' },
      { name = 'nvim_lsp' },
      { name = opts.snippet_engine, max_item_count = 5 },
      { name = 'path',    max_item_count = 5 },
      { name = 'cmdline', max_item_count = 5 },
      { name = 'buffer',  max_item_count = 5 },
    }

    keymaps.insert[opts.mappings.docs_down] = { function() cmp.scroll_docs(-4) end, '', group = 'cmp' }
    keymaps.insert[opts.mappings.docs_up] = { function() cmp.scroll_docs(4) end, '', group = 'cmp' }
    keymaps.insert[opts.mappings.complete] = { function() cmp.complete() end, '', group = 'cmp' }
    keymaps.insert[opts.mappings.close] = { function() cmp.abort() end, '', group = 'cmp' }
    vim.keymap.set('c', opts.mappings.close, function() cmp.close() end, { silent = true, noremap = true })

    if opts.completion_style == 'tab' then
      keymaps.insert['<Tab>'] = { function() cmp.confirm({ select = true }) end, '', group = 'cmp' }
      keymaps.insert['<Down>'] = { function() cmp.select_next_item() end, '', group = 'cmp' }
      keymaps.insert['<Up>'] = { function() cmp.select_prev_item() end, '', group = 'cmp' }
    end
    if opts.completion_style == 'enter' then
      keymaps.insert['<CR>'] = { function() cmp.confirm({ select = true }) end, '', group = 'cmp' }
      keymaps.insert['<Tab>'] = { function() cmp.select_next_item() end, '', group = 'cmp' }
      keymaps.insert['<S-Tab>'] = { function() cmp.select_prev_item() end, '', group = 'cmp' }
    end

    require 'core.config.cmp'.add_sources()
    cmp.setup(opts.config)

    -- Set configuration for specific filetype.
    cmp.setup.filetype('gitcommit', {
      sources = cmp.config.sources({
        -- { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you installed it.
      }, {
        { name = 'buffer' },
      })
    })

    cmp.setup.filetype('markdown', {
      sources = {
        { name = opts.snippet_engine, max_item_count = 5 },
        { name = 'emoji' },
        { name = "dictionary", keyword_length = 2, },
        { name = 'path' },
        { name = 'buffer',     max_item_count = 5 },
      }
    })

    -- Use buffer source for `/`
    cmp.setup.cmdline('/', {
      sources = {
        { name = 'buffer' }
      }
    })

    -- Use cmdline & path source for ':'
    cmp.setup.cmdline(':', {
      sources = {
        { name = 'path' },
        { name = 'cmdline' }
      }
    })

    if opts.use_emoji_source then
      require 'core.plugin.cmp-emoji'
    end
  end
}
