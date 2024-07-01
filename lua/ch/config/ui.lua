return {
  setup = function(opts)
    ch.log('ui.setup', 'set up ui')

    if opts.input.enabled then
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require 'ch.ui.input' (...)
      end
    end

    if opts.cursor.enabled then
      require 'ch.ui.cursor'.setup()
    end

    if opts.statusline.enabled then
      ---@diagnostic disable-next-line: inject-field
      ch.modules.ch.lualine.enabled = false

      require 'ch.ui.statusline.hl'.setup_highlights()
      ---@class ch.types.global
      ---@field statusline fun()
      _G.ch.statusline = function()
        return R 'ch.ui.statusline'.run()
      end
      vim.opt.statusline = "%!v:lua.ch.statusline()"
    end

    if opts.bufferline.enabled then
      require 'ch.ui.bufferline.load'.setup()

      ---@class ch.types.global
      ---@field bufferline fun()
      _G.ch.bufferline = function()
        vim.opt.showtabline = 2
        return R 'ch.ui.bufferline.modules'.run()
      end
      vim.opt.tabline = "%!v:lua.ch.bufferline()"
    end

    if opts.terminal.enabled then
      require 'ch.ui.term'.setup(opts.terminal)
    end
  end,
}
