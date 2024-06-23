local Util = require 'core.utils'

local M = {}

local H = {}

H.get_left_char = function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  return string.sub(line, col, col)
end

---@param char string
---@param type string
---@return boolean
H.is_lsp_trigger = function(char, type)
  local triggers
  local providers = {
    completion = 'completionProvider',
    signature = 'signatureHelpProvider',
  }

  for _, client in pairs(vim.lsp.buf_get_clients()) do
    triggers = vim.tbl_get(client, 'server_capabilities', providers[type], 'triggerCharacters')
    if vim.tbl_contains(triggers or {}, char) then return true end
  end
  return false
end

---@return boolean
H.is_ts_trigger = function()
  local node = vim.treesitter.get_node()
  if not node then
    return false
  end
  return node:type() == 'arguments'
end

---@param capability string
---@return boolean
H.has_lsp_clients = function(capability)
  local clients = vim.lsp.buf_get_clients()
  if vim.tbl_isempty(clients) then return false end
  if not capability then return true end

  for _, c in pairs(clients) do
    local has_capability = vim.tbl_get(c.server_capabilities, capability)
    if has_capability then return true end
  end
  return false
end

function M.close_signature()
  H.close_action_window(H.signature)
end

function M.auto_signature()
  if not H.has_lsp_clients('signatureHelpProvider') then return end

  local left_char = H.get_left_char()
  local char_is_trigger = left_char == '(' or H.is_lsp_trigger(left_char, 'signature') or H.is_ts_trigger()
  if not char_is_trigger then
    M.close_signature()
    return
  end

  M.show_signature_window()
end

--- Cache for signature help
---@alias signature_cache { bufnr?: integer, text?: string, win_id?: integer, lsp: signature_cache.lsp }
---@alias signature_cache.lsp { id: integer, status?: string, result?: any, cancel_fun?: function }
---@type signature_cache
H.signature = {
  bufnr = nil,
  text = nil,
  win_id = nil,
  lsp = { id = 0, status = nil, result = nil, cancel_fun = nil },
}

---@param cache signature_cache
---@param id integer
H.is_lsp_current = function(cache, id) return cache.lsp.id == id and cache.lsp.status == 'sent' end

H.signature_window_lines = function()
  local signature_data = H.process_lsp_response(H.signature.lsp.result, H.process_signature_response)
  -- Each line is a single-line active signature string from one attached LSP
  -- client. Each highlight range is a table which indicates (if not empty)
  -- what parameter to highlight for every LSP client's signature string.
  local lines, hl_ranges = {}, {}
  for _, t in pairs(signature_data) do
    -- `t` is allowed to be an empty table (in which case nothing is added) or
    -- a table with two entries. This ensures that `hl_range`'s integer index
    -- points to an actual line in future buffer.
    table.insert(lines, t.label)
    table.insert(hl_ranges, t.hl_range)
  end

  return lines, hl_ranges
end

H.process_signature_response = function(response)
  if not response.signatures or vim.tbl_isempty(response.signatures) then return {} end

  -- Get active signature (based on textDocument/signatureHelp specification)
  local signature_id = response.activeSignature or 0
  -- This is according to specification: "If ... value lies outside ...
  -- defaults to zero"
  local n_signatures = vim.tbl_count(response.signatures or {})
  if signature_id < 0 or signature_id >= n_signatures then signature_id = 0 end
  local signature = response.signatures[signature_id + 1]

  -- Get displayed signature label
  local signature_label = signature.label

  -- Get start and end of active parameter (for highlighting)
  local hl_range = {}
  local n_params = vim.tbl_count(signature.parameters or {})
  local has_params = signature.parameters and n_params > 0

  -- Take values in this order because data inside signature takes priority
  local parameter_id = signature.activeParameter or response.activeParameter or 0
  local param_id_inrange = 0 <= parameter_id and parameter_id < n_params

  -- Computing active parameter only when parameter id is inside bounds is not
  -- strictly based on specification, as currently (v3.16) it says to treat
  -- out-of-bounds value as first parameter. However, some clients seems to use
  -- those values to indicate that nothing needs to be highlighted.
  -- Sources:
  -- https://github.com/microsoft/pyright/pull/1876
  -- https://github.com/microsoft/language-server-protocol/issues/1271
  if has_params and param_id_inrange then
    local param_label = signature.parameters[parameter_id + 1].label

    -- Compute highlight range based on type of supplied parameter label: can
    -- be string label which should be a part of signature label or direct start
    -- (inclusive) and end (exclusive) range values
    local first, last = nil, nil
    if type(param_label) == 'string' then
      first, last = signature_label:find(vim.pesc(param_label))
      -- Make zero-indexed and end-exclusive
      if first then
        first, last = first - 1, last
      end
    elseif type(param_label) == 'table' then
      first, last = unpack(param_label)
    end
    if first then hl_range = { first = first, last = last } end
  end

  -- Return nested table because this will be a second argument of
  -- `vim.list_extend()` and the whole inner table is a target value here.
  return { { label = signature_label, hl_range = hl_range } }
end

H.process_lsp_response = function(request_result, processor)
  if not request_result then return {} end

  local res = {}
  for client_id, item in pairs(request_result) do
    if not item.err and item.result then vim.list_extend(res, processor(item.result, client_id) or {}) end
  end

  return res
end

H.signature_window_opts = function()
  local win_config = core.lib.options:get('lsp', 'signature', 'window')

  local border_type = win_config.border or core.config.ui.float_border

  local lines = vim.api.nvim_buf_get_lines(H.signature.bufnr, 0, -1, {})
  local height, width = H.floating_dimensions(lines, win_config.height, win_config.width)

  -- Compute position
  local win_line = vim.fn.winline()
  local border_offset = win_config.border == 'none' and 0 or 2
  local space_above = win_line - 1 - border_offset
  local space_below = vim.api.nvim_win_get_height(0) - win_line - border_offset

  local anchor, row, space
  if height <= space_above or space_below <= space_above then
    anchor, row, space = 'SW', 0, space_above
  else
    anchor, row, space = 'NW', 1, space_below
  end

  -- Possibly adjust floating window dimensions to fit screen
  if space < height then
    height, width = H.floating_dimensions(lines, space, win_config.width)
  end

  -- Get zero-indexed current cursor position
  local bufpos = vim.api.nvim_win_get_cursor(0)
  bufpos[1] = bufpos[1] - 1

  return {
    relative = 'win',
    bufpos = bufpos,
    anchor = anchor,
    row = row,
    col = 0,
    width = width,
    height = height,
    focusable = false,
    style = 'minimal',
    border = border_type,
  }
end

-- Helpers for floating windows -----------------------------------------------

H.buffer_opts = function(cache)
  if not cache.bufnr then return end
  -- Make this buffer a scratch (can close without saving)
  vim.api.nvim_set_option_value('buftype', 'nofile', { buf = cache.bufnr })
end

---@param cache signature_cache
---@param name string
H.ensure_buffer = function(cache, name)
  if type(cache.bufnr) == 'number' and vim.api.nvim_buf_is_valid(cache.bufnr) then return end

  cache.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(cache.bufnr, name)
  H.buffer_opts(cache)
end

-- Returns tuple of height and width
---@param lines string[]
---@param max_height integer
---@param max_width integer
---@return integer
---@return integer
H.floating_dimensions = function(lines, max_height, max_width)
  max_height, max_width = math.max(max_height, 1), math.max(max_width, 1)

  -- Simulate how lines will look in window with `wrap` and `linebreak`.
  -- This is not 100% accurate (mostly when multibyte characters are present
  -- manifesting into empty space at bottom), but does the job
  local lines_wrap = {}
  for _, l in pairs(lines) do
    vim.list_extend(lines_wrap, H.wrap_line(l, max_width))
  end
  -- Height is a number of wrapped lines truncated to maximum height
  local height = math.min(#lines_wrap, max_height)

  -- Width is a maximum width of the first `height` wrapped lines truncated to
  -- maximum width
  local width = 0
  local l_width
  for i, l in ipairs(lines_wrap) do
    -- Use `strdisplaywidth()` to account for 'non-UTF8' characters
    l_width = vim.fn.strdisplaywidth(l)
    if i <= height and width < l_width then width = l_width end
  end
  -- It should already be less that that because of wrapping, so this is "just
  -- in case"
  width = math.min(width, max_width)

  return height, width
end

---@param cache signature_cache
---@param opts vim.api.keyset.win_config
H.open_action_window = function(cache, opts)
  cache.win_id = vim.api.nvim_open_win(cache.bufnr, false, opts)
  vim.api.nvim_set_option_value('wrap', true, { win = cache.win_id })
  vim.api.nvim_set_option_value('linebreak', true, { win = cache.win_id })
  vim.api.nvim_set_option_value('breakindent', false, { win = cache.win_id })
end

---@param cache signature_cache
H.close_action_window = function(cache)
  if type(cache.win_id) == 'number' and vim.api.nvim_win_is_valid(cache.win_id) then
    vim.api.nvim_win_close(cache.win_id, true)
  end
  cache.win_id = nil

  -- For some reason 'buftype' might be reset. Ensure that buffer is scratch.
  H.buffer_opts(cache)
end

---@param s string|table
H.is_whitespace = function(s)
  if type(s) == 'string' then return s:find('^%s*$') end
  if type(s) == 'table' then
    for _, val in pairs(s) do
      if not H.is_whitespace(val) then return false end
    end
    return true
  end
  return false
end

-- Simulate splitting single line `l` like how it would look inside window with
-- `wrap` and `linebreak` set to `true`
---@param l string
---@param width integer
---@return table
H.wrap_line = function(l, width)
  local res = {}

  local success, width_id = true, nil
  -- Use `strdisplaywidth()` to account for multibyte characters
  while success and vim.fn.strdisplaywidth(l) > width do
    -- Simulate wrap by looking at breaking character from end of current break
    -- Use `pcall()` to handle complicated multibyte characters (like Chinese)
    -- for which even `strdisplaywidth()` seems to return incorrect values.
    success, width_id = pcall(vim.str_byteindex, l, width)

    if success then
      local break_match = vim.fn.match(l:sub(1, width_id):reverse(), '[- \t.,;:!?]')
      -- If no breaking character found, wrap at whole width
      local break_id = width_id - (break_match < 0 and 0 or break_match)
      table.insert(res, l:sub(1, break_id))
      l = l:sub(break_id + 1)
    end
  end
  table.insert(res, l)

  return res
end

function M.show_signature_window()
  -- If there is no received LSP result, make request and exit
  if H.signature.lsp.status ~= 'received' then
    local current_id = H.signature.lsp.id + 1
    H.signature.lsp.id = current_id
    H.signature.lsp.status = 'sent'

    local bufnr = vim.api.nvim_get_current_buf()
    local params = vim.lsp.util.make_position_params()

    local cancel_fun = vim.lsp.buf_request_all(bufnr, 'textDocument/signatureHelp', params, function(result)
      if not H.is_lsp_current(H.signature, current_id) then return end

      H.signature.lsp.status = 'received'
      H.signature.lsp.result = result

      -- Trigger `show_signature` again to take 'received' route
      M.show_signature_window()
    end)

    -- Cache cancel function to disable requests when they are not needed
    H.signature.lsp.cancel_fun = cancel_fun

    return
  end

  -- Make lines to show in floating window
  local lines, hl_ranges = H.signature_window_lines()
  H.signature.lsp.status = 'done'

  -- Close window and exit if there is nothing to show
  if not lines or H.is_whitespace(lines) then
    H.close_action_window(H.signature)
    return
  end

  -- Make markdown code block
  table.insert(lines, 1, '```' .. vim.bo.filetype)
  table.insert(lines, '```')

  -- If not already, create a permanent buffer for signature
  H.ensure_buffer(H.signature, 'MiniCompletion:signature-help')

  -- Add `lines` to signature buffer. Use `wrap_at` to have proper width of
  -- 'non-UTF8' section separators.
  vim.lsp.util.stylize_markdown(H.signature.bufnr, lines, { wrap_at = core.modules.core.lsp.opts.signature.window.width })

  -- Add highlighting of active parameter
  for i, hl_range in ipairs(hl_ranges) do
    if not vim.tbl_isempty(hl_range) and hl_range.first and hl_range.last then
      vim.api.nvim_buf_add_highlight(
        H.signature.bufnr,
        0,
        'ActiveParameter',
        i - 1,
        hl_range.first,
        hl_range.last
      )
    end
  end

  -- If window is already opened and displays the same text, don't reopen it
  local cur_text = table.concat(lines, '\n')
  if H.signature.win_id and cur_text == H.signature.text then return end

  -- Cache lines for later checks if window should be reopened
  H.signature.text = cur_text

  -- Ensure window is closed
  H.close_action_window(H.signature)

  -- Compute floating window options
  local opts = H.signature_window_opts()
  if #hl_ranges > 0 then
    opts.bufpos[2] = opts.bufpos[2] - hl_ranges[1].first - 1
  end

  -- Ensure that window doesn't open when it shouldn't
  if vim.fn.mode() == 'i' then H.open_action_window(H.signature, opts) end
end

return M
