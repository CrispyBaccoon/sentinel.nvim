local parts = require 'ch.parts'

return {
  setup = function(opts)
    vim.api.nvim_create_autocmd('BufWritePost', {
      -- command = 'source <afile>',
      callback = function(props)
        vim.notify('reloading module: ' .. CONFIG_MODULE .. '\t' .. props.file, vim.log.levels.INFO)
        local status, config = SR(CONFIG_MODULE)
        if not status then
          require 'ch.utils'.log('autocmds.config_reload', 'config module ' .. CONFIG_MODULE .. ' was not found', 'error')
          return
        end
        if type(config) == 'table' then
          require 'ch'.setup(config)
        end
        return
      end,
      group = opts.group_id,
      pattern = 'lua/' .. CONFIG_MODULE .. '/init.lua',
      desc = 'config:reload:' .. CONFIG_MODULE,
    })
  end,
  ---@param spec ch.types.module.spec
  create_reload = function (module, spec)
    local file_name = string.gsub(module, '[.]', '/')
    vim.api.nvim_create_autocmd('BufWritePost', {
      callback = function (props)
        vim.notify('reloading module: ' .. module .. '\t' .. props.file, vim.log.levels.INFO)
        package.loaded[module] = nil
        parts.load(module, spec)
      end,
      group = ch.group_id,
      pattern = 'lua/' .. file_name .. '.lua',
      desc = 'config:reload:' .. module,
    })
  end,
}
