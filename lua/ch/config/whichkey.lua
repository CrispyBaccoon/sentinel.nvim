return {
  module = {
    default = {
      opts = {
        config = {
          -- key labels are imported from ui->key_labels
          key_labels = nil,
        },
      },
    },
  },
  setup = function(opts)
    ch.log('whichkey.setup', 'loading whichkey.')
    require('ch.plugins').load 'whichkey'

    local ok, which = SR_L 'which-key'
    if not ok then
      return
    end

    if not opts.config.key_labels then
      opts.config.key_labels =
        ch.config.ui.key_labels
    end
    which.setup(opts.config)

    which.register {
      ['.'] = { name = 'toggle' },
      [','] = { name = 'edit' },
      ['<leader>'] = {
        f = { name = 'find' },
        s = { name = 'show' },
        g = { name = 'go' },
      },
    }
  end,
}
