-- create async thread
---@param fn function callback function in async thread
---@param ... any arguments to callback function
---@return userdata
_G.async_wrap = function(fn, ...)
  return vim.uv.new_thread(fn, ...)
end
