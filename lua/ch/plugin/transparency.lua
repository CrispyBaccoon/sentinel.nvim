local function hl_override(name, props)
  local hl = ch.lib.hl.get_hl { name = name }
  return vim.tbl_deep_extend('force', hl, props or {})
end

local function glassify(name)
  return hl_override(name, { bg = 'none' })
end

return {
  setup = function()
    ch.lib.autocmd.create {
      event = 'ColorScheme', priority = GC.priority.handle.colorscheme.transparency,
      desc = 'load transparency hls',
      fn = function(_)
        -- reload highlights after colorscheme is switched/reloaded with changes
        require 'ch.plugin.transparency'.create()
        require 'ch.plugin.transparency'.fix()
      end,
    }
  end,
  get = function()
    return _G.saved_highlights.transparent or require 'ch.plugin.transparency'.create()
  end,
  create = function()
    _G.saved_highlights = {
      transparent = {
        Normal = { fg = ch.lib.hl:get('ui', 'fg'), bg = 'none' },
        SignColumn = glassify 'SignColumn',
        LineNr = glassify 'LineNr',
        TabLine = glassify 'TabLine',
        TabLineFill = glassify 'TabLineFill',
      },
      normal = {},
    }
    local save = vim.tbl_keys(_G.saved_highlights.transparent)
    vim.iter(ipairs(save)):each(function(_, name)
      _G.saved_highlights.normal[name] = ch.lib.hl.get_hl { name = name }
    end)
    return _G.saved_highlights.transparent
  end,
  ---@param mode boolean
  set = function(mode)
    if mode then
      ch.lib.hl.apply(require 'ch.plugin.transparency'.get())
    else
      ch.lib.hl.apply(_G.saved_highlights.normal)
    end
  end,
  fix = function()
    if ch.config.ui.transparent_background ~= nil then
      require 'ch.plugin.transparency'.set(ch.config.ui.transparent_background)
    end
  end,
  toggle = function()
    if ch.config.ui.transparent_background ~= nil then
      ch.config.ui.transparent_background = not ch.config.ui.transparent_background
      require 'ch.plugin.transparency'.fix()
    end
  end,
}
