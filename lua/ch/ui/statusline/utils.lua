---@class vim.var_accessor
---@field statusline_winid integer

local utils = {}

function utils.stwinid()
  return vim.g.statusline_winid or 0
end

function utils.stbufnr()
  return vim.api.nvim_win_get_buf(utils.stwinid())
end

function utils.is_activewin()
  return vim.api.nvim_get_current_win() == utils.stwinid()
end

---@type { [NvMode]: { [1]: string, [2]: string } }
utils.modes = {
  ["n"] = { "NORMAL", "normal" },
  ["no"] = { "NORMAL (no)", "normal" },
  ["nov"] = { "NORMAL (nov)", "normal" },
  ["noV"] = { "NORMAL (noV)", "normal" },
  ["noCTRL-V"] = { "NORMAL", "normal" },
  ["niI"] = { "NORMAL i", "normal" },
  ["niR"] = { "NORMAL r", "normal" },
  ["niV"] = { "NORMAL v", "normal" },
  ["nt"] = { "NTERMINAL", "normal" },
  ["ntT"] = { "NTERMINAL (ntT)", "normal" },

  ["v"] = { "VISUAL", "visual" },
  ["vs"] = { "V-CHAR (Ctrl O)", "visual" },
  ["V"] = { "V-LINE", "visual" },
  ["Vs"] = { "V-LINE", "visual" },
  ['\22'] = { "V-BLOCK", "visual" },

  ["i"] = { "INSERT", "insert" },
  ["ic"] = { "INSERT (completion)", "insert" },
  ["ix"] = { "INSERT completion", "insert" },

  ["t"] = { "TERMINAL", "normal" },

  ["R"] = { "REPLACE", "insert" },
  ["Rc"] = { "REPLACE (Rc)", "insert" },
  ["Rx"] = { "REPLACEa (Rx)", "insert" },
  ["Rv"] = { "V-REPLACE", "insert" },
  ["Rvc"] = { "V-REPLACE (Rvc)", "insert" },
  ["Rvx"] = { "V-REPLACE (Rvx)", "insert" },

  ["s"] = { "SELECT", "visual" },
  ["S"] = { "S-LINE", "visual" },
  ['\19'] = { "S-BLOCK", "visual" },
  ["c"] = { "COMMAND", "command" },
  ["cv"] = { "COMMAND", "command" },
  ["ce"] = { "COMMAND", "command" },
  ["r"] = { "PROMPT", "command" },
  ["rm"] = { "MORE", "command" },
  ["r?"] = { "CONFIRM", "command" },
  ["x"] = { "CONFIRM", "command" },
  ["!"] = { "SHELL", "command" },
}

---@param mode? NvMode
---@return { label: string, name: string, hl: string, sep_hl: string }
function utils.getmode(mode)
  if not _G.nvmode then return utils.getmode 'n' end
  if not mode then mode = _G.nvmode end

  local mode_label = utils.modes[mode][1]
  local mode_name = utils.modes[mode][2]

  return {
    label = mode_label,
    name = mode_name,
    hl = function(section)
      return utils.construct_hl(mode_name, section)
    end,
    sep_hl = function(section)
      return utils.construct_hl(mode_name, section, true)
    end,
  }
end

---@param mode 'normal'|'insert'|'visual'|'command'
---@param section 'a'|'b'|'c'
---@param sep? boolean
---@return string
function utils.construct_hl(mode, section, sep)
  return '%#St_' .. mode .. '_' .. (sep and (section .. '_sep') or section) .. '#'
end

return utils
