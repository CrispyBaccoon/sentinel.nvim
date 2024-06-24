---@class ch.types.lib.highlight
---@field apply fun(hls: HLGroups )
ch.lib.hl = ch.lib.hl or {}
ch.lib.hl.apply = require 'ch.plugin.highlight'.apply

---@class ch.types.lib.highlight
---@field get_hl fun(props: { name: string }): ch.types.hl.highlight
ch.lib.hl.get_hl = function(props)
  return vim.api.nvim_get_hl(0, props)
end

---@class ch.types.lib.highlight
---@field get fun(self, ...: string): integer
function ch.lib.hl:get(...)
  return vim.tbl_get(self.__value, ...)
end
