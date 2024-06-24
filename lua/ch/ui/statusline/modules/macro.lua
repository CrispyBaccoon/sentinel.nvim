return function(fmt)
  local key = vim.fn.reg_recording()
  key = #key > 0 and key or nil
  if not key then
    return
  end

  local str = fmt(key)
  return ch.lib.fmt.space(str)
end
