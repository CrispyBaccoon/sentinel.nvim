local function hl_override(name, props)
  local hl = core.lib.hl.get_hl { name = name }
  return vim.tbl_deep_extend('force', hl, props or {})
end

local function glassify(name)
  return hl_override(name, { bg = 'none' })
end

return {
  setup = function()
    core.lib.autocmd.create {
      event = 'ColorScheme', priority = GC.priority.handle.colorscheme.transparency,
      desc = 'load transparency hls',
      fn = function(_)
        -- reload highlights after colorscheme is switched/reloaded with changes
        require 'core.plugin.transparency'.create()
        require 'core.plugin.transparency'.fix()
      end,
    }
  end,
  get = function()
    return _G.saved_highlights.transparent or require 'core.plugin.transparency'.create()
  end,
  create = function()
    _G.saved_highlights = {
      transparent = {
        Normal = { fg = core.lib.hl:get('ui', 'fg'), bg = 'none' },
        SignColumn = glassify 'SignColumn',
        LineNr = glassify 'LineNr',
        TabLine = glassify 'TabLine',
        TabLineFill = glassify 'TabLineFill',
      },
      normal = {},
    }
    local save = vim.tbl_keys(_G.saved_highlights.transparent)
    for _, name in ipairs(save) do
      _G.saved_highlights.normal[name] = core.lib.hl.get_hl { name = name }
    end
    return _G.saved_highlights.transparent
  end,
  ---@param mode boolean
  set = function(mode)
    if mode then
      core.lib.hl.apply(require 'core.plugin.transparency'.get())
    else
      core.lib.hl.apply(_G.saved_highlights.normal)
    end
  end,
  fix = function()
    if core.config.ui.transparent_background ~= nil then
      require 'core.plugin.transparency'.set(core.config.ui.transparent_background)
    end
  end,
  toggle = function()
    if core.config.ui.transparent_background ~= nil then
      core.config.ui.transparent_background = not core.config.ui.transparent_background
      require 'core.plugin.transparency'.fix()
    end
  end,
}
