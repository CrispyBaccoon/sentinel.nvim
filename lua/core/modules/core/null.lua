return {
  default = {
    opts = {
      ---@type fun(null): table
      ---```lua
      ---function(null)
      ---  return {
      ---    null.builtins.formatting.stylua
      ---  }
      ---end
      ---```
      sources = nil,
      mappings = {
        format = ',fn',
      },
      config = {
        sources = {},
      },
    },
  },
}
