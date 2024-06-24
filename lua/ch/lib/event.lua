---@class ch.types.lib.event
---@field trigger fun(ev: string)
ch.lib.event = {}
ch.lib.event.trigger = require 'ch.load.handle'.start
