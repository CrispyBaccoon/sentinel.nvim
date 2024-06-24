return function()
  local dir_icon = ch.lib.fmt.space(ch.lib.icons.syntax.folder)
  local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  if vim.o.columns > 85 then
    return dir_icon .. dir_name .. ' '
  end
end
