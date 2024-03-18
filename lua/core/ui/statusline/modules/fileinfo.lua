local utils = require 'core.ui.statusline.utils'

return function()
  local bufnr = utils.stbufnr()
  local icon = '󰈚'
  local path = vim.api.nvim_buf_get_name(bufnr)
  local name = (path == '' and 'empty') or path:match '([^/\\]+)[/\\]*$'

  if name ~= 'empty' and core.config.ui.devicons then
    local devicons_present, devicons = pcall(require, 'nvim-web-devicons')

    if devicons_present then
      local ft_icon = devicons.get_icon(name)
      if ft_icon then
        icon = ft_icon
      end
    end
  end

  if vim.bo[bufnr].buftype == '' and vim.bo[bufnr].modified then
    name = name .. ' ' .. core.lib.icons.info.non_empty
  end

  if vim.bo[bufnr].readonly then
    name = name .. ' ' .. core.lib.icons.info.locked
  end

  return core.lib.fmt.space(icon) .. name .. ' '
end
