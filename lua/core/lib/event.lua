---@class core.types.lib.event
---@field trigger fun(ev: string)
core.lib.event = {}
core.lib.event.trigger = require 'core.load.handle'.start
