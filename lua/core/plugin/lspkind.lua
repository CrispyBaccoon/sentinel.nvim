local M = {}

local cmp_hi = {
  CmpItemMenu           = { fg = core.lib.hl:get('syntax', 'constant'), bg = "none", italic = true },

  CmpItemAbbrDeprecated = { fg = core.lib.hl:get('diagnostic', 'warn') },

  CmpItemAbbrMatch      = { fg = core.lib.hl:get('ui', 'match') },
  CmpItemAbbrMatchFuzzy = { link = "CmpItemAbbrMatch" },
}

vim.iter(pairs(cmp_hi)):each(function(hi_group, hl)
  vim.api.nvim_set_hl(0, hi_group, hl)
end)

local kind_icons = {
  Text = core.lib.icons.syntax.text,
  Method = core.lib.icons.syntax.method,
  Function = core.lib.icons.syntax.fn,
  Constructor = core.lib.icons.syntax.constructor,
  Field = core.lib.icons.syntax.field,
  Variable = core.lib.icons.syntax.variable,
  Class = core.lib.icons.syntax.class,
  Interface = core.lib.icons.syntax.interface,
  Module = core.lib.icons.syntax.module,
  Property = core.lib.icons.syntax.property,
  Unit = core.lib.icons.syntax.unit,
  Value = core.lib.icons.syntax.value,
  Enum = core.lib.icons.syntax.enum,
  Keyword = core.lib.icons.syntax.keyword,
  Snippet = core.lib.icons.syntax.snippet,
  Color = core.lib.icons.syntax.color,
  File = core.lib.icons.syntax.file,
  Reference = core.lib.icons.syntax.reference,
  Folder = core.lib.icons.syntax.folder,
  EnumMember = core.lib.icons.syntax.enummember,
  Constant = core.lib.icons.syntax.constant,
  Struct = core.lib.icons.syntax.struct,
  Event = core.lib.icons.syntax.event,
  Operator = core.lib.icons.syntax.operator,
  TypeParameter = core.lib.icons.syntax.typeparameter,
  Namespace = core.lib.icons.syntax.namespace,
  Table = core.lib.icons.syntax.table,
  Object = core.lib.icons.syntax.object,
  Tag = core.lib.icons.syntax.tag,
  Array = core.lib.icons.syntax.array,
  Boolean = core.lib.icons.syntax.boolean,
  Number = core.lib.icons.syntax.number,
  Null = core.lib.icons.syntax.null,
  String = core.lib.icons.syntax.string,
  Package = core.lib.icons.syntax.package,
}

M.kind_icons = kind_icons

local kind_hl = {
  Text          = core.lib.hl:get('syntax', 'text'),
  Method        = core.lib.hl:get('syntax', 'method'),
  Function      = core.lib.hl:get('syntax', 'fn'),
  Constructor   = core.lib.hl:get('syntax', 'constructor'),
  Field         = core.lib.hl:get('syntax', 'field'),
  Variable      = core.lib.hl:get('syntax', 'variable'),
  Class         = core.lib.hl:get('syntax', 'class'),
  Interface     = core.lib.hl:get('syntax', 'interface'),
  Module        = core.lib.hl:get('syntax', 'module'),
  Property      = core.lib.hl:get('syntax', 'property'),
  Unit          = core.lib.hl:get('syntax', 'unit'),
  Value         = core.lib.hl:get('syntax', 'value'),
  Enum          = core.lib.hl:get('syntax', 'enum'),
  Keyword       = core.lib.hl:get('syntax', 'keyword'),
  Snippet       = core.lib.hl:get('syntax', 'snippet'),
  Color         = core.lib.hl:get('syntax', 'color'),
  File          = core.lib.hl:get('syntax', 'file'),
  Reference     = core.lib.hl:get('syntax', 'reference'),
  Folder        = core.lib.hl:get('syntax', 'folder'),
  EnumMember    = core.lib.hl:get('syntax', 'enummember'),
  Constant      = core.lib.hl:get('syntax', 'constant'),
  Struct        = core.lib.hl:get('syntax', 'struct'),
  Event         = core.lib.hl:get('syntax', 'event'),
  Operator      = core.lib.hl:get('syntax', 'operator'),
  TypeParameter = core.lib.hl:get('syntax', 'typeparameter'),
  Namespace     = core.lib.hl:get('syntax', 'namespace'),
  Table         = core.lib.hl:get('syntax', 'table'),
  Object        = core.lib.hl:get('syntax', 'object'),
  Tag           = core.lib.hl:get('syntax', 'tag'),
  Array         = core.lib.hl:get('syntax', 'array'),
  Boolean       = core.lib.hl:get('syntax', 'boolean'),
  Number        = core.lib.hl:get('syntax', 'number'),
  Null          = core.lib.hl:get('syntax', 'null'),
  String        = core.lib.hl:get('syntax', 'string'),
  Package       = core.lib.hl:get('syntax', 'package'),
}

vim.iter(pairs(kind_hl)):each(function(kind, item)
  local hi_group = string.format('CmpItemKind%s', kind)
  core.lib.hl.apply {
    [hi_group] = { fg = item },
  }
end)

local max_count = 26

function M.create_formatter(mode)
  local modes = {
    evergreen = {
      fields = { 'abbr', 'kind', 'menu' },
      format = function(entry, vim_item)
        -- Kind icons
        vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
        -- Source
        local menu_item = ({
          buffer = "Buffer",
          nvim_lsp = "LSP",
          luasnip = "LuaSnip",
          nvim_lua = "Lua",
          latex_symbols = "LaTeX",
        })[entry.source.name]
        vim_item.menu = menu_item and string.format('  (%s)', menu_item) or ''

        local word = vim_item.abbr
        local len = string.len(word)
        if len < max_count then
          vim_item.abbr = word .. string.rep(' ', max_count - len)
        else
          vim_item.abbr = string.sub(word, 0, max_count - 3) .. '...'
        end
        return vim_item
      end,
    },
    nyoom = {
      fields = { 'kind', 'abbr', 'menu' },
      format = function(_, vim_item)
        -- Kind icons
        local kind = vim_item.kind
        vim_item.menu = kind
        vim_item.kind = core.lib.fmt.space(kind_icons[kind])
        -- Source

        local word = vim_item.abbr
        local len = string.len(word)
        if len < max_count then
          vim_item.abbr = word .. string.rep(' ', max_count - len)
        else
          vim_item.abbr = string.sub(word, 0, max_count - 3) .. '...'
        end
        return vim_item
    end,
    },
  }
  local format = modes[mode]
  if not format then
    format = modes['evergreen']
  end
  return format
end


return M
