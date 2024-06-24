---@param group_name any
---@param desc_width integer
---@param lhs_width integer
local function generate_group(group_name, desc_width, lhs_width)
  local maps = require 'keymaps.data'.get_group(group_name)
  local str_keys = {}
  for _, map in pairs(maps.normal) do
    local desc = string.sub(map.desc, 0, desc_width)

    local lhs = ch.lib.keymaps.fmt(map.lhs)
    lhs = string.sub(lhs, 0, lhs_width)
    str_keys[#str_keys + 1] = { desc, lhs }
  end

  return str_keys
end

---@param str string
---@return { [1]: integer, [2]: integer }
local function dry_trim_str(str)
  local _str = vim.split(str, '')
  local _start = 0
  local _end = 0

  local i = 1
  while i <= #_str and _start == 0 do
    if _str[i] ~= ' ' then
      _start = i
    end
    i = i + 1
  end

  i = #_str
  while i > 0 and _end == 0 do
    if _str[i] ~= ' ' then
      _end = i
    end
    i = i - 1
  end

  return { _start, (#_str - _end) * -1 }
end

return {
  open = function(props)
    local api = vim.api
    -- create buffer
    local buf = api.nvim_create_buf(false, true)
    local win = api.nvim_get_current_win()

    api.nvim_win_set_buf(win, buf)

    vim.opt_local.filetype = "cheatsheet"
    vim.g.cheatsheet_displayed = true

    local groups = require 'keymaps.data'.get_groups()
    local gr_i = 1

    --[[
{[1]  {[2]
{''}  {''}
{''}  {''}
{''}  {''}
{''}  {''}
{''}  {''}
{''}  {''}
}     }
    ]]
    --
    local cheatsheet = {}

    local max_width = api.nvim_win_get_width(win)
    local desc_width = 30
    local lhs_width = 12
    local hor_pad = 1
    local spacing = 2
    local column_spacing = 1
    local group_width = desc_width + lhs_width + (hor_pad * 2) + spacing + column_spacing
    local groups_per_line = math.floor(max_width / group_width)
    local max_groups_per_col = math.ceil(#groups / groups_per_line)
    local _center_padding = max_width - group_width * groups_per_line
    local center_padding = { math.floor(_center_padding / 2), math.ceil(_center_padding / 2) }

    local win_height = api.nvim_win_get_height(win)

    local cur_gr_in_line = 1
    while cur_gr_in_line <= groups_per_line and gr_i <= #groups do
      cheatsheet[cur_gr_in_line] = {}

      local local_gr_i = 1
      local y = 0
      while y < win_height and gr_i <= #groups and local_gr_i <= max_groups_per_col do
        local name = groups[gr_i]
        local str_keys = generate_group(name, desc_width, lhs_width)
        if #str_keys > 0 then
          local section = {}

          local gr_len = vim.fn.strwidth(name)
          local gr_space = group_width - gr_len
          local gr_padding = { math.floor(gr_space / 2), math.ceil(gr_space / 2) }
          local gr_header = string.rep(' ', gr_padding[1]) .. name .. string.rep(' ', gr_padding[2])

          section[1] = string.rep(' ', group_width)
          section[2] = gr_header
          section[3] = string.rep(' ', group_width)

          for _, str_tuple in ipairs(str_keys) do
            local desc = str_tuple[1] .. string.rep(' ', desc_width - vim.fn.strwidth(str_tuple[1]))
            local lhs = string.rep(' ', lhs_width - vim.fn.strwidth(str_tuple[2])) .. str_tuple[2]
            section[#section + 1] = string.rep(' ', hor_pad) ..
                desc .. string.rep(' ', spacing) .. lhs .. string.rep(' ', hor_pad) .. string.rep(' ', column_spacing)
          end

          section[#section + 1] = string.rep(' ', group_width)

          cheatsheet[cur_gr_in_line][local_gr_i] = section
          local_gr_i = local_gr_i + 1
        end

        -- end
        gr_i = gr_i + 1
      end

      -- end
      cur_gr_in_line = cur_gr_in_line + 1
    end

    local result = {}

    -- make all lines available
    for i = 1, win_height do
      result[i] = ""
    end

    require 'ch.plugin.hl'.load()
    -- local cheatsheet_ns = api.nvim_create_namespace 'cheatsheet'
    api.nvim_set_hl(0, "CheatsheetTitle", { link = 'TelescopeTitle' })
    api.nvim_set_hl(0, "CheatsheetLine", { fg = ch.lib.hl:get('ui', 'fg'), bg = ch.lib.hl:get('ui', 'current') })

    ---@type { ['title'|'lines']: { [1]: integer, [2]: { from: integer, to: integer } }[] }
    local hls = {
      title = {},
      lines = {},
    }

    local y = 1
    local empty = false
    while not empty do
      empty = true -- assume current line is empty until proven wrong
      local current_line = ''

      for column_x, column in ipairs(cheatsheet) do
        local part = ''
        local empty_part = true

        -- find group at current y
        local _y = 0
        for _, group in ipairs(column) do
          local rel_i = y - _y
          if (#group) >= rel_i and empty_part then
            part = group[rel_i]
            empty_part = false
            if rel_i == 2 then
              local pos = dry_trim_str(part)
              local x_start = center_padding[1] + (column_x - 1) * group_width
              local x_end = x_start + group_width - 1
              x_start = x_start + (pos[1] - 2)
              x_end = x_end + pos[2] + 2
              hls.title[#hls.title + 1] = { y - 1, { from = x_start, to = x_end } }
            end
            if rel_i > 1 then
              local x_start = center_padding[1] + (column_x - 1) * group_width
              local x_end = x_start + group_width - 1
              hls.lines[#hls.lines + 1] = { y - 1, { from = x_start, to = x_end } }
            end
          end
          _y = _y + #group
        end

        if empty_part then
          -- last group in this column has been passed
          part = string.rep(' ', group_width)
        end
        current_line = current_line .. part

        empty = empty and empty_part or false
      end

      if not empty then
        result[y] = current_line
      end

      y = y + 1
    end

    for i, _ in ipairs(result) do
      result[i] = string.rep(' ', center_padding[1]) .. result[i] .. string.rep(' ', center_padding[2])
    end

    api.nvim_buf_set_lines(buf, 0, -1, false, result)

    for _, hl in ipairs(hls.title) do
      api.nvim_buf_add_highlight(buf, 0, 'CheatsheetTitle', hl[1], hl[2].from, hl[2].to)
    end
    for _, hl in ipairs(hls.lines) do
      api.nvim_buf_add_highlight(buf, 0, 'CheatsheetLine', hl[1], hl[2].from, hl[2].to)
    end

    vim.keymap.set("n", "q", function() vim.api.nvim_buf_delete(buf, { force = true }) end, { buffer = true })

    -- buf only options
    vim.opt_local.buflisted = false
    vim.opt_local.modifiable = false
    vim.opt_local.number = false
    vim.opt_local.list = false
    vim.opt_local.relativenumber = false
    vim.opt_local.wrap = false
    vim.opt_local.cul = false
    vim.opt_local.colorcolumn = "0"
  end,
}
