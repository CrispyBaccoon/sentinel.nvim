return {
  module = {
    default = {
      opts = {
        config = {
          replace = {
            -- key labels are imported from ui->key_labels
            key = nil,
            desc = {
              { "<Plug>%(?(.*)%)?", "%1" },
              { "^%+", "" },
              { "<[cC]md>", "" },
              { "<[cC][rR]>", "" },
              { "<[sS]ilent>", "" },
              { "^lua%s+", "" },
              { "^call%s+", "" },
              { "^:%s*", "" },
            },
          }
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

    if not opts.config.replace then
      local default_key_labels = {
        function(key)
          return require("which-key.view").format(key)
        end,
      }
      vim.list_extend(default_key_labels, ch.config.ui.key_labels)

      opts.config.replace.key = default_key_labels
    end
    which.setup(opts.config)

    which.register {
      { '.', group = 'toggle' },
      { ',', group = 'edit' },
      { '<leader>f', group = 'find' },
      { '<leader>s', group = 'show' },
      { '<leader>g', group = 'go' },
    }
  end,
}
