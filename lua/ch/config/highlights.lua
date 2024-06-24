return {
  setup = function(opts)
    -- termguicolors
    vim.opt.termguicolors = true
    -- foldcolumn off
    vim.opt.foldcolumn = "0"
    -- global statusline
    vim.opt.laststatus = 3

    -- fold chars
    vim.opt.fillchars:append { fold = " ", foldclose = ">" }
    -- endofbuffer chars
    vim.opt.fillchars:append { eob = " " }

    vim.opt.listchars:append { tab = "» ", trail = "·" }
    local tabwidth = ch.lib.options:get('options', 'tab_width')
    vim.opt.listchars:append { lead = '·', leadmultispace = ('·%s'):format((' '):rep(tabwidth-1)) }

    vim.opt.background = "dark"

    vim.cmd([[ command! Highlights source $VIMRUNTIME/syntax/hitest.vim ]])

    if opts.fix then
      ch.lib.autocmd.create {
        event = 'ColorScheme', priority = GC.priority.handle.colorscheme.fix,
        desc = 'fix highlights',
        fn = function(_)
          opts.fix()
        end
      }
    end
  end
}
