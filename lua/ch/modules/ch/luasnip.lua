return {
  default = {
    opts = {
      mappings = {
        -- jump in dynamic snippets
        jump_next = '<m-l>',
        jump_prev = '<m-h>',
        -- choose item in choice node
        choose_next = '<c-j>',
        choose_prev = '<c-k>',
      },
      config = {
        -- This tells LuaSnip to remember to keep around the last snippet.
        -- You can jump back into it even if you move outside of the selection
        history = true,
        updateevents = 'InsertLeave',
        enable_autosnippets = false,
        ext_opts = nil,
      },
      -- can import a table of languages; set to true to import all
      -- import_languages = { 'rust', 'go', 'lua', 'c', 'cpp', 'html', 'js', 'bash' },
      import_languages = true,
    },
  },
}
