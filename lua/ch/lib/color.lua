ch.lib.color = {}

---@alias ch.types.lib.color.Color__internal integer|'none'
---@alias ch.types.lib.color.Color__rgb { r: integer, g: integer, b: integer }
---@alias ch.types.lib.color.Color ch.types.lib.color.Color__rgb
---@alias ch.types.lib.color.Color__hsl { hue: integer, sat: integer, lum: integer }

---@class ch.types.lib.color
---@field rgb fun(props: ch.types.lib.color.Color__rgb): integer
function ch.lib.color.rgb(props)
  if not props or not props.r or not props.g or not props.b then return 0 end
  return ch.lib.math.components_to_hex { [1] = props.r, [2] = props.g, [3] = props.b }
end

---@class ch.types.lib.color
---@field mix fun(ratio, props): integer
---@param ratio number Ratio of color2 mixed into color1; 1.0 means only color2
---@param props tuple<ch.types.lib.color.Color__internal>
function ch.lib.color.mix(ratio, props)
  if not props or not props[1] or not props[2] then return 0 end
  local color1 = ch.lib.math.hex_to_rgb(props[1])
  local color2 = ch.lib.math.hex_to_rgb(props[2])
  if not props or not props[1] or not props[2] then return 0 end

  local mix = { r = 0, g = 0, b = 0 }
  for slider, _ in pairs(mix) do
    mix[slider] = math.floor((1 - ratio) * color1[slider] + ratio * color2[slider])
  end

  return ch.lib.color.rgb(mix)
end

---@class ch.types.lib.color
---@field hsl_mix fun(ratio, props): integer
---@param ratio { hue?: number, sat?: number, lum?: number } Ratio of color2 mixed into color1; 1.0 means only color2
---@param props tuple<ch.types.lib.color.Color__internal>
function ch.lib.color.hsl_mix(ratio, props)
  if not props or not props[1] or not props[2] then return 0 end
  local color1__rgb = ch.lib.math.hex_to_rgb(props[1])
  local color2__rgb = ch.lib.math.hex_to_rgb(props[2])
  local color1 = ch.lib.color.rgb_to_hsl(color1__rgb)
  local color2 = ch.lib.color.rgb_to_hsl(color2__rgb)

  local mix = { hue = 0, lum = 0, sat = 0 }
  for slider, _ in pairs(mix) do
    local r = ratio[slider]
    if ratio[slider] then
      mix[slider] = (1 - r) * color1[slider] + r * color2[slider]
    else
      mix[slider] = color1[slider]
    end
  end

  local mix__rgb = ch.lib.color.hsl_to_rgb(mix)
  return ch.lib.color.rgb(mix__rgb)
end

---@class ch.types.lib.color
---@field rgb_to_hsl fun(props: ch.types.lib.color.Color__rgb): ch.types.lib.color.Color__hsl
function ch.lib.color.rgb_to_hsl(props)
  local hsl = { hue = 0, sat = 0, lum = 0 }
  -- make r, g, and b fractions of 1
  local r = props.r / 255;
  local g = props.g / 255;
  local b = props.b / 255;

  -- find greatest and smallest channel values
  local cmin = math.min(r, g, b)
  local cmax = math.max(r, g, b)
  local delta = cmax - cmin
  local h = 0
  local s = 0
  local l = 0

  -- calculate hue
  -- no difference
  if (delta == 0) then
    h = 0
    -- red is max
  elseif (cmax == r) then
    h = ((g - b) / delta) % 6
    -- green is max
  elseif (cmax == g) then
    h = (b - r) / delta + 2
    -- blue is max
  else
    h = (r - g) / delta + 4
  end

  h = math.floor(h * 60);

  -- make negative hues positive behind 360°
  if (h < 0) then
    h = h + 360
  end

  -- calculate lightness
  l = (cmax + cmin) / 2

  -- calculate saturation
  s = delta == 0 and 0 or delta / (1 - math.abs(2 * l - 1))

  hsl = {
    hue = h, -- as x
    sat = s, -- as 0.x
    lum = l, -- as 0.x
  }

  return hsl
end

---@class ch.types.lib.color
---@field hsl_to_rgb fun(props: ch.types.lib.color.Color__hsl): ch.types.lib.color.Color__rgb
function ch.lib.color.hsl_to_rgb(props)
  local color = { r = 0, g = 0, b = 0 }

  -- all as fractions
  local h = props.hue / 360
  local s = props.sat
  local l = props.lum
  local r = 0
  local g = 0
  local b = 0

  if s == 0 then
    -- achromatic
    r = l
    g = l
    b = l
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = ch.lib.color.hue_to_rgb(p, q, h + 1 / 3)
    g = ch.lib.color.hue_to_rgb(p, q, h)
    b = ch.lib.color.hue_to_rgb(p, q, h - 1 / 3)
  end

  color = {
    r = math.ceil(r * 255),
    g = math.ceil(g * 255),
    b = math.ceil(b * 255),
  }
  return color
end

---@class ch.types.lib.color
---@field hue_to_rgb fun(p, q, t): number
function ch.lib.color.hue_to_rgb(p, q, t)
  if t < 0 then t = t + 1 end
  if t > 1 then t = t - 1 end
  if (t < 1 / 6) then
    return p + (q - p) * 6 * t
  end
  if (t < 1 / 2) then
    return q
  end
  if (t < 2 / 3) then
    return p + (q - p) * (2 / 3 - t) * 6
  end
  return p
end

---@class ch.types.lib.color
---@field color_overlay fun(ratio, props): integer
---@param ratio number Ratio of color2 overlayed ontop of color1; 1.0 means only color2
---@param props tuple<ch.types.lib.color.Color__internal>
function ch.lib.color.color_overlay(ratio, props)
  if not props[1] or not props[2] then return 0 end
  local f = ch.lib.math.hex_to_rgb(props[1])
  local t = ch.lib.math.hex_to_rgb(props[2])

  if (ratio < 0) then
    ratio = ratio * -1
  end
  local p = 1 - ratio;

  local r = math.ceil(((p * f.r ^ 2) + (ratio * t.r ^ 2)) ^ 0.5)
  local g = math.ceil(((p * f.g ^ 2) + (ratio * t.g ^ 2)) ^ 0.5)
  local b = math.ceil(((p * f.b ^ 2) + (ratio * t.b ^ 2)) ^ 0.5)

  local color = ch.lib.color.rgb { r = r, g = g, b = b }

  return color
end
