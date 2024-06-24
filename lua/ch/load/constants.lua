---@class ch.types.constants
GC = {}

---@class ch.types.constants.priority
---@field signs { ['lsp'|'git']: integer }
---@field handle ch.types.constants.priority.handle

---@class ch.types.constants.priority.handle
---@field colorscheme table<'hl'|'theme'|'plugin'|'fix'|'transparency', integer>

---@class ch.types.constants
---@field priority ch.types.constants.priority
GC.priority = {
  signs = {
    -- starts at 16 to provide room for other plugins
    lsp = 16,
    git = 18,
  },
  handle = {
    colorscheme = {
      hl = 2,
      theme = 4,
      plugin = 6,
      fix = 26,
      transparency = 100,
    },
  },
}
