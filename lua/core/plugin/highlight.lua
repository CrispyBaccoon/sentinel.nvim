---@diagnostic disable duplicate-doc-alias

---@alias Color { [1]: string, [2]: integer }
---@alias ColorSpec { [1]: Color, [2]: Color, link: string, reverse: boolean }

---@param group string
---@param colors ColorSpec
local function set_hi(group, colors)
  if type(colors) ~= 'table' or vim.tbl_isempty(colors) then
    return
  end

  colors.fg = colors.fg or colors[1] or 'none'
  colors.bg = colors.bg or colors[2] or 'none'

  ---@type vim.api.keyset.highlight
  local color = {}

  vim.iter(pairs(colors)):each(function(k, v)
    color[k] = v
  end)

  color.fg = type(colors.fg) == 'table' and colors.fg[1] or colors.fg
  color.bg = type(colors.bg) == 'table' and colors.bg[1] or colors.bg
  color.ctermfg = type(colors.fg) == 'table' and colors.fg[2] or 'none'
  color.ctermbg = type(colors.bg) == 'table' and colors.bg[2] or 'none'
  color[1] = nil
  color[2] = nil
  color.name = nil

  vim.api.nvim_set_hl(0, group, color)
end

---@alias HLGroups { [string]: ColorSpec }

---@param hlgroups HLGroups
local function set_highlights(hlgroups)
  vim.iter(pairs(hlgroups)):each(function(group, colors)
    set_hi(group, colors)
  end)
end

return {
  apply = function(props)
    set_highlights(props)
  end,
}
