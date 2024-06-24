ch.lib.math = {}

---@class ch.types.lib.math
---@field parse_hex_str fun(props: string): integer
function ch.lib.math.parse_hex_str(props)
  if not props or type(props) ~= 'string' then return end
  local n = string.sub(props, 2)
  return tonumber(n, 16)
end

---@class ch.types.lib.math
---@field components_to_hex fun(props: Array<integer>): integer
function ch.lib.math.components_to_hex(props)
  return vim.iter(ipairs(props)):fold(0, function(n, i, v)
    local m = #props - i
    return n + ((256 ^ m) * v)
  end)
end

---@class ch.types.lib.math
---@field hex_to_components fun(n: integer, v: integer): Array<integer>
function ch.lib.math.hex_to_components(n, v)
  local _components = {}
  local components = {}
  local _n = v

  for i = 1, n, 1 do
    _components[i] = (256 ^ (n - i))
    components[i] = math.floor(_n / _components[i])
    components[i] = components[i] > 0 and components[i] or 0
    _n = _n - components[i] * _components[i]
  end

  return components
end

---@class ch.types.lib.math
---@field hex_to_rgb fun(n): ch.types.lib.color.Color
---@param n ch.types.lib.color.Color__internal
function ch.lib.math.hex_to_rgb(n)
  if n == 'none' then
    n = 0
  end
  ---@diagnostic disable-next-line: param-type-mismatch
  local components = ch.lib.math.hex_to_components(3, n)
  return { r = components[1], g = components[2], b = components[3] }
end

---@class ch.types.lib.math
---@field avg fun(props: integer[]): integer
function ch.lib.math.avg(props)
  local sum = vim.iter(ipairs(props)):fold(0, function(sum, _, v)
    return sum + v
  end)
  return sum / #props
end
