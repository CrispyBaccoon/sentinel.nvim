return function()
  local icon = ch.lib.fmt.space(ch.lib.icons.syntax.text)

  local current_line = vim.fn.line('.', vim.g.statusline_winid)
  local total_line = vim.fn.line('$', vim.g.statusline_winid)
  local text = math.modf((current_line / total_line) * 100) .. tostring '%%'
  text = string.format('%4s', text)

  text = (current_line == 1 and 'Top') or text
  text = (current_line == total_line and 'Bot') or text

  return icon .. text .. ' '
end
