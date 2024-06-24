-- adapted from @NvChad https://github.com/NvChad/ui/blob/1737a2a98e18b635480756e817564b60ff31fc53/lua/nvchad/tabufline/lazyload.lua

return {
  setup = function()
    local opts = ch.lib.options:get('ui', 'bufferline')
    local ok, bufferline = SR_L 'ch.ui.bufferline'
    if not ok then return end

    require 'ch.ui.bufferline.hl'.setup_highlights()

    -- store listed buffers in tab local var
    vim.t.bufs = vim.api.nvim_list_bufs()

    local listed_bufs = {}

    for _, val in ipairs(vim.t.bufs) do
      if vim.bo[val].buflisted then
        table.insert(listed_bufs, val)
      end
    end

    vim.t.bufs = listed_bufs

    -- autocmds for tabufline -> store bufnrs on bufadd, bufenter events
    -- thx to https://github.com/ii14 & stores buffer per tab -> table
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufEnter', 'tabnew' }, {
      group = ch.group_id,
      callback = function(args)
        local bufs = vim.t.bufs

        if vim.t.bufs == nil then
          vim.t.bufs = vim.api.nvim_get_current_buf() == args.buf and {}
            or { args.buf }
        else
          -- check for duplicates
          if
            not vim.tbl_contains(bufs, args.buf)
            and (args.event == 'BufEnter' or vim.bo[args.buf].buflisted or args.buf ~= vim.api.nvim_get_current_buf())
            and vim.api.nvim_buf_is_valid(args.buf)
            and vim.bo[args.buf].buflisted
          then
            table.insert(bufs, args.buf)
            vim.t.bufs = bufs
          end
        end

        -- remove unnamed buffer which isnt current buf & modified
        if args.event == 'BufAdd' then
          local first_buf = vim.t.bufs[1]

          if
            #vim.api.nvim_buf_get_name(first_buf) == 0
            and not vim.api.nvim_get_option_value('modified', { buf = first_buf })
          then
            table.remove(bufs, 1)
            vim.t.bufs = bufs
          end
        end
      end,
    })

    vim.api.nvim_create_autocmd('BufDelete', {
      group = ch.group_id,
      callback = function(args)
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
          local bufs = vim.t[tab].bufs
          if bufs then
            for i, bufnr in ipairs(bufs) do
              if bufnr == args.buf then
                table.remove(bufs, i)
                vim.t[tab].bufs = bufs
                break
              end
            end
          end
        end
      end,
    })
  end,
}
