local M = {}

M.module = {
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

local function use_theme(theme_name)
  local themes = {
    minimal = {
      borderchars = {
        { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        prompt = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
        results = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
        preview = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
      },
      highlights = {
        TelescopeTitle = { link = 'FloatTitle' },
        TelescopeNormal = { link = 'Normal' },
        TelescopePromptNormal = { 'none', ch.lib.hl:get('ui', 'bg_accent') },
        TelescopeSelection = { 'none', ch.lib.hl:get('ui', 'current') },
        TelescopeMatching = { link = 'Search' },
        TelescopeBorder = { link = 'FloatBorder' },
      },
    },
    main = {
      borderchars = {
        { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
        prompt = { " ", "│", "─", "│", '│', '│', "╯", "╰" },
        results = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
        preview = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
      },
      highlights = {
        TelescopeTitle = { link = 'FloatTitle' },
        TelescopeNormal = { link = 'Normal' },
        TelescopePromptNormal = { 'none', ch.lib.hl:get('ui', 'bg_accent') },
        TelescopeSelection = { 'none', ch.lib.hl:get('ui', 'current') },
        TelescopeMatching = { link = 'Search' },
        TelescopeBorder = { link = 'FloatBorder' },
      },
    },
  }

  if not theme_name then
    return
  end
  vim.api.nvim_set_hl(0, 'Telescope', {})

  local theme = themes[theme_name]
  if not theme then
    ch.log('telescope.setup', 'theme with name `' .. theme_name .. '` not found', 'error')
    return
  end

  require 'telescope'.setup {
    defaults = {
      borderchars = theme.borderchars,
    },
  }

  require 'ch.plugin.highlight'.apply(theme.highlights)
end

---@class chTelescopeOpts
---@field config TelescopeConfig
---@field use_fzf? boolean
---@field theme? 'main'|'minimal'
---@field mappings { [string]: string }

---@param opts chTelescopeOpts
M.setup = function(opts)
  require 'telescope'.setup(opts.config)

  if opts.use_fzf then
    require 'ch.plugins'.load 'telescope_fzf'
    require 'telescope'.load_extension 'fzf'
  end

  require 'ch.plugins'.load 'telescope_select'
  require 'telescope'.load_extension 'ui-select'

  if opts.theme and type(opts.theme) == 'string' then
    ch.lib.autocmd.create {
      event = 'ColorScheme', priority = GC.priority.handle.colorscheme.plugin,
      desc = 'load telescope hls',
      fn = function(_)
        use_theme(ch.modules.ch.telescope.opts.theme)
      end
    }
  end

  local pickers = require 'ch.plugin.telescope'.picker
  local style = require 'ch.plugin.telescope'.get_style
  local builtins = require 'telescope.builtin'

  Keymap.group {
    group = 'telescope',
    { 'normal', opts.mappings.resume,           builtins.resume,    'resume' },
    { 'normal', opts.mappings.find_files,       pickers.find_files, 'find files' },
    { 'normal', opts.mappings.live_grep,        pickers.grep,       'find string' },
    { 'normal', opts.mappings.simple_find_file, pickers.explorer,   'find file' },
    { 'normal', opts.mappings.symbols,          pickers.symbols,    'find symbols' },
    { 'normal', opts.mappings.git_files,        pickers.git_files,  'find git file' },
    { 'normal', opts.mappings.buffers,          builtins.buffers,   'find buffer' },
    { 'normal', opts.mappings.keymaps,          builtins.keymaps,   'find keymap' },
    { 'normal', opts.mappings.help_tags,        builtins.help_tags, 'find help tag' },
    { 'normal', opts.mappings.quickfix,         builtins.quickfix,  'search in qf list' },
    { 'normal', opts.mappings.colorscheme,
      function() builtins.colorscheme(style('dropdown', { prompt_title = 'select colorscheme' })) end, 'find colorscheme' },
    { 'normal', opts.mappings.search,
      function() R 'ch.plugin.telescope'.picker.grep_current_file {} end, 'find in file' },
    { 'normal', opts.mappings.mappings, require 'keymaps'.telescope, 'find mapping' },
  }
end

return M
