return {
  default = {
    opts = {
      theme = 'main',
      mappings = {
        -- resume last telescope search
        resume = '<leader>;',
        find_files = '<leader><leader>',
        live_grep = '<leader>fr',
        simple_find_file = '<leader>ff',
        search = '<leader>f/',
        symbols = '<leader>fs',
        git_files = '<leader>fg',
        buffers = "<leader>fb",
        keymaps = "<leader>fk",
        mappings = "<leader>fm",
        help_tags = "<leader>fh",
        colorscheme = "<C-t>",
        quickfix = '<leader>fq',
      },
      config = {
        defaults = {
          prompt_prefix = '$ ',
          file_previewer = require 'telescope.previewers'.vim_buffer_cat.new,
          path_display = nil,
          file_ignore_patterns = { 'node_modules', '%.git/' },
          borderchars = {
            { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
            prompt = { "─", "│", "─", "│", '┌', '┐', "┘", "└" },
            results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
            preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,             -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = 'smart_case', -- or 'ignore_case' or 'respect_case', defaults to 'smart_case'
          },
          ['ui-select'] = {
            require 'ch.plugin.telescope'.style.dropdown,
          },
        },
        pickers = {
          find_files = {
            disable_devicons = false,
          },
        },
      },
    },
  },
  overwrite = {},
}
