-- adapted from @NvChad https://github.com/NvChad/ui/blob/1737a2a98e18b635480756e817564b60ff31fc53/lua/nvchad/tabufline/init.lua

local M = {}
local api = vim.api

M.bufilter = function()
  local bufs = vim.t.bufs or nil

  if not bufs then
    return {}
  end

  for i, nr in ipairs(bufs) do
    if not vim.api.nvim_buf_is_valid(nr) then
      table.remove(bufs, i)
    end
  end

  vim.t.bufs = bufs
  return bufs
end

M.get_buf_index = function(bufnr)
  for i, value in ipairs(M.bufilter()) do
    if value == bufnr then
      return i
    end
  end
end

M.bufferline_next = function()
  local bufs = M.bufilter() or {}
  local cur_buf_index = M.get_buf_index(api.nvim_get_current_buf())

  if not cur_buf_index then
    vim.cmd("b" .. vim.t.bufs[1])
    return
  end

  vim.cmd(cur_buf_index == #bufs and "b" .. bufs[1] or "b" .. bufs[cur_buf_index + 1])
end

M.bufferline_prev = function()
  local bufs = M.bufilter() or {}
  local cur_buf_index = M.get_buf_index(api.nvim_get_current_buf())

  if not cur_buf_index then
    vim.cmd("b" .. vim.t.bufs[1])
    return
  end

  vim.cmd(cur_buf_index == 1 and "b" .. bufs[#bufs] or "b" .. bufs[cur_buf_index - 1])
end

M.close_buffer = function(bufnr)
  if vim.bo.buftype == "terminal" then
    vim.cmd(vim.bo.buflisted and "set nobl | enew" or "hide")
  else
    if not vim.t.bufs then
      vim.cmd "bd"
      return
    end

    bufnr = bufnr or api.nvim_get_current_buf()
    local cur_buf_index = M.get_buf_index(bufnr)
    local bufhidden = vim.bo.bufhidden

    -- force close floating wins
    if bufhidden == "wipe" then
      vim.cmd "bw"
      return

      -- handle listed bufs
    elseif cur_buf_index and #vim.t.bufs > 1 then
      local new_buf_index = cur_buf_index == #vim.t.bufs and -1 or 1
      vim.cmd("b" .. vim.t.bufs[cur_buf_index + new_buf_index])

    -- handle unlisted
    elseif not vim.bo.buflisted then
      local tmpbufnr = vim.t.bufs[1]

      if vim.g.nv_previous_buf and vim.api.nvim_buf_is_valid(vim.g.nv_previous_buf) then
        tmpbufnr = vim.g.nv_previous_buf
      end

      vim.cmd("b" .. tmpbufnr .. " | bw" .. bufnr)
      return
    else
      vim.cmd "enew"
    end

    if not (bufhidden == "delete") then
      vim.cmd("confirm bd" .. bufnr)
    end
  end

  vim.cmd "redrawtabline"
end

-- closes tab + all of its buffers
M.close_all_bufs = function(action)
  local bufs = vim.t.bufs

  if action == "close_tab" then
    vim.cmd "tabclose"
  end

  for _, buf in ipairs(bufs) do
    M.close_buffer(buf)
  end

  if action ~= "close_tab" then
    vim.cmd "enew"
  end
end

-- closes all bufs except current one
M.close_other_bufs = function()
  for _, buf in ipairs(vim.t.bufs) do
    if buf ~= api.nvim_get_current_buf() then
      vim.api.nvim_buf_delete(buf, {})
    end
  end

  vim.cmd "redrawtabline"
end

-- closes all other buffers right or left
M.close_bufs_at_direction = function(x)
  local bufindex = M.get_buf_index(api.nvim_get_current_buf())

  for i, bufnr in ipairs(vim.t.bufs) do
    if (x == "left" and i < bufindex) or (x == "right" and i > bufindex) then
      M.close_buffer(bufnr)
    end
  end
end

M.move_buf = function(n)
  local bufs = vim.t.bufs

  for i, bufnr in ipairs(bufs) do
    if bufnr == vim.api.nvim_get_current_buf() then
      if n < 0 and i == 1 or n > 0 and i == #bufs then
        bufs[1], bufs[#bufs] = bufs[#bufs], bufs[1]
      else
        bufs[i], bufs[i + n] = bufs[i + n], bufs[i]
      end

      break
    end
  end

  vim.t.bufs = bufs
  vim.cmd "redrawtabline"
end

-- btn onclick functions --

vim.g.BfTabsToggled = 0

vim.cmd [[
function! Bf_GoToBuf(bufnr,_,__,___)
  execute 'b'..a:bufnr
endfunction
]]

vim.cmd [[
function! Bf_KillBuf(bufnr,_,__,___)
  call luaeval('require("ch.ui.bufferline").close_buffer(_A)', a:bufnr)
endfunction
]]

vim.cmd [[
function! Bf_NewTab(_,__,___,____)
  tabnew
endfunction
]]
vim.cmd [[
function! Bf_GotoTab(tabnr,_,__,___)
  execute a:tabnr ..'tabnext'
endfunction
]]
vim.cmd [[
function! Bf_TabClose(_,__,___,____)
  lua require('ch.ui.bufferline').close_all_bufs('close_tab')
endfunction
]]
vim.cmd [[
function! Bf_CloseAllBufs(_,__,___,____)
  lua require('ch.ui.bufferline').close_all_bufs()
endfunction
]]
vim.cmd [[
function! Bf_ToggleTabs(_,__,___,____)
  let g:BfTabsToggled = !g:BfTabsToggled | redrawtabline
endfunction
]]

return M
