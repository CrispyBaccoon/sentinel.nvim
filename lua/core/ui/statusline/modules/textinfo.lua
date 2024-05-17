local utils = require 'core.ui.statusline.utils'

return function()
  local bufnr = utils.stbufnr()

  if vim.bo[bufnr].buftype == 'nofile' then
    return ''
  end

  return CUTIL.FILE_INFO(bufnr, true)
end
