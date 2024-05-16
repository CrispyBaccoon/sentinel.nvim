-- adapted from @lsp_lines.nvim https://git.sr.ht/~whynothugo/lsp_lines.nvim/tree/cf2306dd332e34a3e91075b40bdd4f6db824b2ee

local Util = require 'core.utils'

local M = {}

---@alias core.types.diagnostic_lines.ns 'chai/virtual_lines'
---@type core.types.diagnostic_lines.ns
M.namespace = 'chai/virtual_lines'

---@type table<integer, string>
local HIGHLIGHT_GROUPS = {
  [vim.diagnostic.severity.ERROR] = 'DiagnosticVirtualTextError',
  [vim.diagnostic.severity.WARN] = 'DiagnosticVirtualTextWarn',
  [vim.diagnostic.severity.INFO] = 'DiagnosticVirtualTextInfo',
  [vim.diagnostic.severity.HINT] = 'DiagnosticVirtualTextHint',
}

---@type table<'SPACE'|'DIAGNOSTIC'|'OVERLAP'|'BLANK', string>
local STR_ENUM = {
  SPACE = 'space',
  DIAGNOSTIC = 'diagnostic',
  OVERLAP = 'overlap',
  BLANK = 'blank',
}

---@class core.types.diagnostic_lines.opts
---@field enabled boolean
---@field severity integer only show virtual lines for severity
---@field only_current_line boolean only render for current line
---@field highlight_whole_line boolean highlight empty space to the left of a diagnostic

M.virtual_line_handlers = {
  ---@param namespace number
  ---@param bufnr number
  ---@param diagnostics table
  ---@param opts boolean|vim.diagnostic.Opts
  show = function(namespace, bufnr, diagnostics, opts)
    local ns = vim.diagnostic.get_namespace(namespace)
    if not ns.user_data.virt_lines_ns then
      ns.user_data.virt_lines_ns = vim.api.nvim_create_namespace ''
    end
    local vopts = opts[M.namespace] or {}

    vim.api.nvim_clear_autocmds { group = 'LspLines' }
    if vopts.only_current_line then
      vim.api.nvim_create_autocmd('CursorMoved', {
        buffer = bufnr,
        callback = function()
          M.render_current_line(
            diagnostics,
            ns.user_data.virt_lines_ns,
            bufnr,
            opts
          )
        end,
        group = 'LspLines',
      })
      -- Also show diagnostics for the current line before the first CursorMoved event
      M.render_current_line(
        diagnostics,
        ns.user_data.virt_lines_ns,
        bufnr,
        opts
      )
    else
      M.show(ns.user_data.virt_lines_ns, bufnr, diagnostics, opts)
    end
  end,
  ---@param namespace number
  ---@param bufnr number
  hide = function(namespace, bufnr)
    local ns = vim.diagnostic.get_namespace(namespace)
    if ns.user_data.virt_lines_ns then
      M.hide(ns.user_data.virt_lines_ns, bufnr)
      vim.api.nvim_clear_autocmds { group = 'LspLines' }
    end
  end,
}

-- Registers a wrapper-handler to render lsp lines.
---@param opts core.types.diagnostic_lines.opts.virtual_lines
function M.setup(opts)
  Util.log('lsp.diagnostic_lines', 'enabling diagnostic lines')
  -- TODO: On LSP restart (e.g.: diagnostics cleared), errors don't go away.
  vim.api.nvim_create_augroup('LspLines', { clear = true })

  vim.diagnostic.config {
    [M.namespace] = opts or {},
  }
  if not (opts.severity and type(opts.severity) == 'number') then
    opts.severity = 9
  end
  local virt_text_opts = vim.diagnostic.config().virtual_text
  virt_text_opts.severity = { max = opts.severity + 1 }
  vim.diagnostic.config {
    virtual_text = virt_text_opts,
  }
  vim.diagnostic.handlers[M.namespace] = M.virtual_line_handlers
end

---@return boolean
M.toggle = function()
  local opts = vim.diagnostic.config()[M.namespace]
  opts = opts or { enabled = false }
  opts.enabled = not opts.enabled
  vim.diagnostic.config { [M.namespace] = opts }
  return opts.enabled
end

---@param diagnostics vim.Diagnostic[]
---@param ns integer
---@param bufnr integer
---@param opts boolean|core.types.diagnostic_lines.opts
function M.render_current_line(diagnostics, ns, bufnr, opts)
  local current_line_diag = {}
  local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1

  for _, diagnostic in pairs(diagnostics) do
    local show = diagnostic.end_lnum
        and (lnum >= diagnostic.lnum and lnum <= diagnostic.end_lnum)
      or (lnum == diagnostic.lnum)
    if show then
      table.insert(current_line_diag, diagnostic)
    end
  end

  M.show(ns, bufnr, current_line_diag, opts)
end

-- Returns the distance between two columns in cells.
--
-- Some characters (like tabs) take up more than one cell. A diagnostic aligned
-- under such characters needs to account for that and add that many spaces to
-- its left.
---@param bufnr integer
---@param lnum integer
---@param start_col integer
---@param end_col integer
---@return integer
local function distance_between_cols(bufnr, lnum, start_col, end_col)
  local lines = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)
  if vim.tbl_isempty(lines) then
    -- This can only happen is the line is somehow gone or out-of-bounds.
    return 1
  end

  local sub = string.sub(lines[1], start_col, end_col)
  return vim.fn.strdisplaywidth(sub, 0) -- these are indexed starting at 0
end

---@param namespace integer
---@param bufnr integer
---@param diagnostics vim.Diagnostic[]
---@param opts boolean|vim.diagnostic.Opts
function M.show(namespace, bufnr, diagnostics, opts)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end
  vim.validate {
    namespace = { namespace, 'n' },
    bufnr = { bufnr, 'n' },
    diagnostics = {
      diagnostics,
      vim.islist,
      'a list of diagnostics',
    },
    opts = { opts, 't', true },
  }
  local vopts = opts[M.namespace] or {}

  table.sort(diagnostics, function(a, b)
    if a.lnum ~= b.lnum then
      return a.lnum < b.lnum
    else
      return a.col < b.col
    end
  end)

  if vopts.severity and type(vopts.severity) == 'number' then
    diagnostics = vim.tbl_filter(function(d)
      return d.severity <= vopts.severity
    end, diagnostics)
  end

  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  if #diagnostics == 0 then
    return
  end
  local highlight_groups = HIGHLIGHT_GROUPS

  -- This loop reads line by line, and puts them into stacks with some
  -- extra data, since rendering each line will require understanding what
  -- is beneath it.
  local line_stacks = {}
  local prev_lnum = -1
  local prev_col = 0
  for _, diagnostic in ipairs(diagnostics) do
    if line_stacks[diagnostic.lnum] == nil then
      line_stacks[diagnostic.lnum] = {}
    end

    local stack = line_stacks[diagnostic.lnum]

    if diagnostic.lnum ~= prev_lnum then
      table.insert(stack, {
        STR_ENUM.SPACE,
        string.rep(
          ' ',
          distance_between_cols(bufnr, diagnostic.lnum, 0, diagnostic.col)
        ),
      })
    elseif diagnostic.col ~= prev_col then
      -- Clarification on the magic numbers below:
      -- +1: indexing starting at 0 in one API but at 1 on the other.
      -- -1: for non-first lines, the previous col is already drawn.
      table.insert(stack, {
        STR_ENUM.SPACE,
        string.rep(
          ' ',
          distance_between_cols(
            bufnr,
            diagnostic.lnum,
            prev_col + 1,
            diagnostic.col
          ) - 1
        ),
      })
    else
      table.insert(stack, { STR_ENUM.OVERLAP, diagnostic.severity })
    end

    if diagnostic.message:find '^%s*$' then
      table.insert(stack, { STR_ENUM.BLANK, diagnostic })
    else
      table.insert(stack, { STR_ENUM.DIAGNOSTIC, diagnostic })
    end

    prev_lnum = diagnostic.lnum
    prev_col = diagnostic.col
  end

  for lnum, lelements in pairs(line_stacks) do
    local virt_lines = {}

    -- We read in the order opposite to insertion because the last
    -- diagnostic for a real line, is rendered upstairs from the
    -- second-to-last, and so forth from the rest.
    for i = #lelements, 1, -1 do -- last element goes on top
      if lelements[i][1] == STR_ENUM.DIAGNOSTIC then
        local diagnostic = lelements[i][2]
        local empty_space_hi
        if vopts.highlight_whole_line == false
        then
          empty_space_hi = ''
        else
          empty_space_hi = highlight_groups[diagnostic.severity]
        end

        local left = {}
        local overlap = false
        local multi = 0

        -- Iterate the stack for this line to find elements on the left.
        for j = 1, i - 1 do
          local type = lelements[j][1]
          local data = lelements[j][2]
          if type == STR_ENUM.SPACE then
            if multi == 0 then
              table.insert(left, { data, empty_space_hi })
            else
              table.insert(left, {
                string.rep('─', data:len()),
                highlight_groups[diagnostic.severity],
              })
            end
          elseif type == STR_ENUM.DIAGNOSTIC then
            -- If an overlap follows this, don't add an extra column.
            if lelements[j + 1][1] ~= STR_ENUM.OVERLAP then
              table.insert(left, { '│', highlight_groups[data.severity] })
            end
            overlap = false
          elseif type == STR_ENUM.BLANK then
            if multi == 0 then
              table.insert(left, { '└', highlight_groups[data.severity] })
            else
              table.insert(left, { '┴', highlight_groups[data.severity] })
            end
            multi = multi + 1
          elseif type == STR_ENUM.OVERLAP then
            overlap = true
          end
        end

        local center_symbol
        if overlap and multi > 0 then
          center_symbol = '┼'
        elseif overlap then
          center_symbol = '├'
        elseif multi > 0 then
          center_symbol = '┴'
        else
          center_symbol = '└'
        end
        -- local center_text =
        local center = {
          {
            string.format('%s%s', center_symbol, '──── '),
            highlight_groups[diagnostic.severity],
          },
        }

        -- > [!NOTE] We can draw on the left side if and only if:
        -- > a. Is the last one stacked this line.
        -- > b. Has enough space on the left.
        -- > c. Is just one line.
        -- > d. Is not an overlap.

        local msg
        if diagnostic.code then
          msg = string.format('%s: %s', diagnostic.code, diagnostic.message)
        else
          msg = diagnostic.message
        end
        for msg_line in msg:gmatch '([^\n]+)' do
          local vline = {}
          vim.list_extend(vline, left)
          vim.list_extend(vline, center)
          vim.list_extend(
            vline,
            { { msg_line, highlight_groups[diagnostic.severity] } }
          )

          table.insert(virt_lines, vline)

          -- Special-case for continuation lines:
          if overlap then
            center = {
              { '│', highlight_groups[diagnostic.severity] },
              { '     ', empty_space_hi },
            }
          else
            center = { { '      ', empty_space_hi } }
          end
        end
      end
    end

    vim.api.nvim_buf_set_extmark(
      bufnr,
      namespace,
      lnum,
      0,
      { virt_lines = virt_lines }
    )
  end
end

---@param namespace number
---@param bufnr number
function M.hide(namespace, bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
end

return M
