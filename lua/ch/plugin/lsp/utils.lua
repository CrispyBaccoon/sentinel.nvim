local H = {}

---@param method string
---@param params table?
---@param handler function
---@return table<integer, integer>
---@return function
function H.request(method, params, handler)
  vim.validate({
    method = { method, 's' },
    handler = { handler, 'f', true },
  })
  return vim.lsp.buf_request(0, method, params, handler)
end

---@param method string
---@param params table?
---@param options table?
---@return table<integer, integer>
---@return function
function H.request_with_options(method, params, options)
  local req_handler
  if options then
    req_handler = function(err, result, ctx, config)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      local handler = client.handlers[method] or vim.lsp.handlers[method] or function() end
      handler(err, result, ctx, vim.tbl_extend('force', config or {}, options))
    end
  end
  return H.request(method, params, req_handler)
end

return H
