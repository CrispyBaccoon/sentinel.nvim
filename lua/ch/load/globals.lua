---@type string
CR = CR or "~/.config"

---@type fun(v: string): string
ENV = function(v)
    if not vim.fn.has_key(vim.fn.environ(), v) then
        return ""
    end
    return vim.fn.environ()[v]
end

---@type fun(v: string): string
CR_PATH = function (v)
    return CR .. "/" .. v
end

---@generic T : any
---@param v T
---@return T
P = function (v)
 print(vim.inspect(v))
 return v
end

--- Secure reload module
---@param module_name string
---@param starts_with_only? boolean
---@return boolean
---@return any|nil|string
SR = function(module_name, starts_with_only)
  -- Default to starts with only
  if starts_with_only == nil then
    starts_with_only = true
  end

  -- TODO: Might need to handle cpath / compiled lua packages? Not sure.
  local matcher
  if not starts_with_only then
    matcher = function(pack)
      return string.find(pack, module_name, 1, true)
    end
  else
    local module_name_pattern = vim.pesc(module_name)
    matcher = function(pack)
      return string.find(pack, "^" .. module_name_pattern)
    end
  end

  -- Handle impatient.nvim automatically.
  ---@diagnostic disable-next-line: undefined-field
  local luacache = (_G.__luacache or {}).cache

  vim.iter(pairs(package.loaded)):each(function(pack, _)
    if matcher(pack) then
      package.loaded[pack] = nil

      if luacache then
        luacache[pack] = nil
      end
    end
  end)

  return pcall(require, module_name)
end

--- secure reload and log if module is not found
---@param ... unknown
---@return boolean
---@return any
SR_L = function (...)
  local ok, result = SR(...)
  if not ok then
    vim.notify('error while loading module\n\t' .. result, vim.log.levels.ERROR)
  end
  return ok, result
end


--- wrapper fn for plenary reload
---@param module string
---@param name_only boolean|nil
RELOAD = function(module, name_only)
 return require("plenary.reload").reload_module(module, name_only)
end

--- wrapper fn for module reload and require
---@param name string
---@return any
R = function (name)
 RELOAD(name)
 return require(name)
end

MT = function (t1, t2)
  local tnew = {}
  vim.iter(pairs(t1)):each(function(k, v)
    tnew[k] = v
  end)
  vim.iter(pairs(t2)):each(function(k, v)
    if type(v) == "table" then
      if type(tnew[k] or false) == "table" then
        MT(tnew[k] or {}, t2[k] or {})
      else
        tnew[k] = v
      end
    else
      tnew[k] = v
    end
  end)
  return tnew
end

---@type table<string,fun(buf: integer): string>
CUTIL = {}

---@param buf integer
---@return string|string[]
CUTIL.PATH_DIR = function (buf)
  local path = vim.api.nvim_buf_get_name(buf)
  local parent = vim.fs.dirname(path)
  local dir_name = vim.fn.getcwd()..'/'
  local name = string.gsub(parent, dir_name, '')
  return name
end

--- if in visual mode, returns number of visually selected words
---@param _ integer
---@return string
CUTIL.WORD_COUNT = function (_)
  local w_count = vim.fn.wordcount()
  local count = w_count['visual_words'] or w_count['words'] or 0
  if count == 0 then
    return ""
  end
  return tostring(count)
end

--- if in visual mode, returns number of visually selected lines,
--- else return line count in file
---@param buf integer
---@return integer
CUTIL.LINE_COUNT = function (buf)
  local _vstart = vim.fn.line('v')
  local _vend = vim.fn.line('.')

  local diff = _vend - _vstart
  if diff == 0 then
    return vim.api.nvim_buf_line_count(buf)
  end

  return math.abs(diff)
end

--- return file info based on filetype
--- default: LINE_COUNT
--- markdown: WORD_COUNT
---@param buf integer
---@param show_icon? boolean
---@return string|integer
---@diagnostic disable-next-line: redundant-parameter
CUTIL.FILE_INFO = function (buf, show_icon)
  local type_info = {
    markdown = { 'W', CUTIL.WORD_COUNT },
  }
  local t = vim.filetype.match { buf = buf }
  local info = type_info[t] or { 'L', CUTIL.LINE_COUNT }
  local fn = info[2]
  local text = fn(buf)
  local icon = info[1]

  if show_icon then
    return ' ' .. icon .. text .. ' '
  end
  return text
end
