return {
  default = {
    opts = {
      cursorline = false,
      -- true|false or 'relative' for relative line numbers
      number = true,
      tab_width = 2,
      use_ripgrep = true,
      scrolloff = 2,
      treesitter_folds = false,
      load_plugins = { },
      cmdheight = 0,
      cursorstyle = {
        normal = 'block',
        insert = { 'bar', 25 },
        replace = { 'underscore', 20 },
      },
      clipboard = 'selection',
    },
  },
}
