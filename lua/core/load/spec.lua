Spec = Spec or {}

Spec.defaults = {
  lazy = true,
  priority = 500,
}

setmetatable(Spec, {
  __call = function(t, props)
    if type(props) ~= 'table' then return end
    local spec = props
    vim.iter(pairs(t.defaults)):each(function(k, v)
      spec[k] = v
    end)
    return spec
  end
})

--- adds priority and lazy fields to plugin spec
--- example:
--- ```lua
--- return Spec.colorscheme {
---   'comfysage/evergarden',
---   opts = {},
--- }
--- ```
--- is the same as:
--- ```lua
--- return {
---   'comfysage/evergarden',
---   priority = 1200,
---   lazy = true,
---   opts = {},
--- }
--- ```
---@param props LazyPluginSpec
---@return LazyPluginSpec
function Spec.colorscheme(props)
  ---@type LazyPluginSpec
  local _opts = {
    lazy = true,
    priority = 1200,
  }
  return vim.tbl_deep_extend("force", _opts, props)
end
