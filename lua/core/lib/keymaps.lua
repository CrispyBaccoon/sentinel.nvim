---@class core.types.lib.keymaps
---@field fmt fun(lhs: string): string
core.lib.keymaps = {}
core.lib.keymaps.fmt = require 'core.plugin.keymaps'.fmt
