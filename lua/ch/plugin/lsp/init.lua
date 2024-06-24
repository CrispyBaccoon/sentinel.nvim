local H = require 'ch.plugin.lsp.utils'

local M = {}

---@param location table a single `Location` or `LocationLink`
---@param opts table
---@return integer|nil buffer id of float window
---@return integer|nil window id of float window
function M.preview_location(location, opts)
  local context = opts.context or 0
  -- location may be LocationLink or Location (more useful for the former)
  local uri = location.targetUri or location.uri
  if uri == nil then
    return
  end
  local bufnr = vim.uri_to_bufnr(uri)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end
  local range = location.targetRange or location.range
  local start_line = range.start.line
  start_line = start_line > context and start_line - context or 0
  local end_line = range['end'].line + 1 + context
  local contents = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line, false)
  local syntax = vim.bo[bufnr].syntax
  if syntax == '' then
    -- When no syntax is set, we use filetype as fallback. This might not result
    -- in a valid syntax definition.
    -- An empty syntax is more common now with TreeSitter, since TS disables syntax.
    syntax = vim.bo[bufnr].filetype
  end
  opts = opts or {}
  opts.focus_id = 'location'
  return vim.lsp.util.open_floating_preview(contents, syntax, opts)
end

function M.peek_definition()
  local params = vim.lsp.util.make_position_params()
  H.request('textDocument/definition', params, function(_, result)
    M.preview_location(result[1], { context = 2 })
  end)
end

return M
