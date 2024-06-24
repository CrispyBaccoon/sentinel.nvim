local api = vim.api
local fn = vim.fn

local bufferline_config = ch.lib.options:get('ui', 'bufferline')

local separator_style = ch.config.ui.separator_style
---@type table<'left'|'right',string>
---@diagnostic disable-next-line: assign-type-mismatch
local separators = ch.lib.icons.separator[separator_style]
if not separators then
  separators = { left = '', right = '' }
end

local bufisvalid = function(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
end

local function new_hl(group1, group2)
  local fg = fn.synIDattr(fn.synIDtrans(fn.hlID(group1)), "fg#")
  local bg = fn.synIDattr(fn.synIDtrans(fn.hlID(group2)), "bg#")
  api.nvim_set_hl(0, "Bfline" .. group1 .. group2, { fg = fg, bg = bg })
  return "%#" .. "Bfline" .. group1 .. group2 .. "#"
end

local function get_btns_width() -- close, theme toggle btn etc
  local width = 6
  if fn.tabpagenr "$" ~= 1 then
    width = width + ((3 * fn.tabpagenr "$") + 2) + 10
    width = not vim.g.BfTabsToggled and 8 or width
  end
  return width
end

local function add_fileInfo(name, bufnr)
  -- check for same buffer names under different dirs
  for _, value in ipairs(vim.t.bufs) do
    if bufisvalid(value) then
      if name == fn.fnamemodify(api.nvim_buf_get_name(value), ":t") and value ~= bufnr then
        local other = {}
        for match in (vim.fs.normalize(api.nvim_buf_get_name(value)) .. "/"):gmatch("(.-)" .. "/") do
          table.insert(other, match)
        end

        local current = {}
        for match in (vim.fs.normalize(api.nvim_buf_get_name(bufnr)) .. "/"):gmatch("(.-)" .. "/") do
          table.insert(current, match)
        end

        name = current[#current]

        for i = #current - 1, 1, -1 do
          local value_current = current[i]
          local other_current = other[i]

          if value_current ~= other_current then
            if (#current - i) < 2 then
              name = value_current .. "/" .. name
            else
              name = value_current .. "/../" .. name
            end
            break
          end
        end
        break
      end
    end
  end

  -- padding around bufname; 24 = bufame length (icon + filename)
  local padding = (24 - #name - 5) / 2
  local maxname_len = 16

  name = (#name > maxname_len and string.sub(name, 1, 14) .. "..") or name
  name = (api.nvim_get_current_buf() == bufnr and "%#BfLineBufOn# " .. name) or ("%#BfLineBufOff# " .. name)

  local str = name
  return ch.lib.fmt.space(str, padding)
end

local function style_buffer_tab(nr)
  local close_btn = "%" .. nr .. "@Bf_KillBuf@ 󰅖 %X"
  local name = (#api.nvim_buf_get_name(nr) ~= 0) and fn.fnamemodify(api.nvim_buf_get_name(nr), ":t") or " No Name "
  name = "%" .. nr .. "@Bf_GoToBuf@" .. add_fileInfo(name, nr) .. "%X"

  -- add numbers to each tab in bufferline
  if bufferline_config.show_numbers then
    for index, value in ipairs(vim.t.bufs) do
      if nr == value then
        name = name .. index
        break
      end
    end
  end

  -- color close btn for focused / hidden  buffers
  if nr == api.nvim_get_current_buf() then
    close_btn = (vim.bo[0].modified and "%" .. nr .. "@Bf_KillBuf@%#BfLineBufOnModified#  ")
        or ("%#BfLineBufOnClose#" .. close_btn)
    name = "%#BfLineBufOn#" .. name .. close_btn
  else
    close_btn = (vim.bo[nr].modified and "%" .. nr .. "@Bf_KillBuf@%#BfLineBufOffModified#  ")
        or ("%#BfLineBufOffClose#" .. close_btn)
    name = "%#BfLineBufOff#" .. name .. close_btn
  end

  return name
end

-- components --
local M = {}

M.bufferlist = function()
  local buffers = {} -- buffersults
  local available_space = vim.o.columns - get_btns_width()
  local current_buf = api.nvim_get_current_buf()
  local has_current = false -- have we seen current buffer yet?

  for _, bufnr in ipairs(vim.t.bufs) do
    if bufisvalid(bufnr) then
      if ((#buffers + 1) * 21) > available_space then
        if has_current then
          break
        end

        table.remove(buffers, 1)
      end

      has_current = (bufnr == current_buf and true) or has_current
      table.insert(buffers, style_buffer_tab(bufnr))
    end
  end

  vim.g.visibuffers = buffers
  return table.concat(buffers) .. "%#BfLineFill#" .. "%=" -- buffers + empty space
end

M.tablist = function()
  local result, number_of_tabs = "", fn.tabpagenr "$"

  if number_of_tabs > 1 then
    for i = 1, number_of_tabs, 1 do
      local tab_hl = ((i == fn.tabpagenr()) and "%#BfLineTabOn# ") or "%#BfLineTabOff# "
      result = result .. ("%" .. i .. "@Bf_GotoTab@" .. tab_hl .. i .. " ")
      result = (i == fn.tabpagenr() and result .. "%#BfLineTabCloseBtn#" .. "%@Bf_TabClose@󰅙 %X") or result
    end

    local is_open = vim.g.BfTabsToggled ~= 1

    local new_tabtn = "%#BfTabTitleSep#" .. separators.left .. "%#BfLineTabNewBtn#" .. "%@Bf_NewTab@  %X"
    local tabstoggleBtn = "%@Bf_ToggleTabs@%#BfTabTitleSep#" .. (is_open and '' or separators.left)
        .. "%#BfTabTitle# TABS " .. (is_open and '' or ch.lib.fmt.space('')) .. " %X"

    local function tabs_closed()
      return tabstoggleBtn
    end
    local function tabs_open()
      return new_tabtn .. tabstoggleBtn .. result
    end

    return is_open and tabs_open()
        or tabs_closed()
  end

  return ""
end

M.buttons = function()
  local CloseAllBufsBtn = "%@Bf_CloseAllBufs@%#BfLineCloseAllBufsBtn#" .. " 󰅖 " .. "%X"
  return CloseAllBufsBtn
end

M.run = function()
  local modules = {
    M.bufferlist(),
    M.tablist(),
    M.buttons(),
  }

  if bufferline_config.overriden_modules then
    bufferline_config.overriden_modules(modules)
  end

  return table.concat(modules)
end

return M
