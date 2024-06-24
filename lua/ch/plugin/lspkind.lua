local M = {}

local cmp_hi = {
  CmpItemMenu           = { fg = ch.lib.hl:get('syntax', 'constant'), bg = "none", italic = true },

  CmpItemAbbrDeprecated = { fg = ch.lib.hl:get('diagnostic', 'warn') },

  CmpItemAbbrMatch      = { fg = ch.lib.hl:get('ui', 'match') },
  CmpItemAbbrMatchFuzzy = { link = "CmpItemAbbrMatch" },
}

vim.iter(pairs(cmp_hi)):each(function(hi_group, hl)
  vim.api.nvim_set_hl(0, hi_group, hl)
end)

local kind_icons = {
  Text = ch.lib.icons.syntax.text,
  Method = ch.lib.icons.syntax.method,
  Function = ch.lib.icons.syntax.fn,
  Constructor = ch.lib.icons.syntax.constructor,
  Field = ch.lib.icons.syntax.field,
  Variable = ch.lib.icons.syntax.variable,
  Class = ch.lib.icons.syntax.class,
  Interface = ch.lib.icons.syntax.interface,
  Module = ch.lib.icons.syntax.module,
  Property = ch.lib.icons.syntax.property,
  Unit = ch.lib.icons.syntax.unit,
  Value = ch.lib.icons.syntax.value,
  Enum = ch.lib.icons.syntax.enum,
  Keyword = ch.lib.icons.syntax.keyword,
  Snippet = ch.lib.icons.syntax.snippet,
  Color = ch.lib.icons.syntax.color,
  File = ch.lib.icons.syntax.file,
  Reference = ch.lib.icons.syntax.reference,
  Folder = ch.lib.icons.syntax.folder,
  EnumMember = ch.lib.icons.syntax.enummember,
  Constant = ch.lib.icons.syntax.constant,
  Struct = ch.lib.icons.syntax.struct,
  Event = ch.lib.icons.syntax.event,
  Operator = ch.lib.icons.syntax.operator,
  TypeParameter = ch.lib.icons.syntax.typeparameter,
  Namespace = ch.lib.icons.syntax.namespace,
  Table = ch.lib.icons.syntax.table,
  Object = ch.lib.icons.syntax.object,
  Tag = ch.lib.icons.syntax.tag,
  Array = ch.lib.icons.syntax.array,
  Boolean = ch.lib.icons.syntax.boolean,
  Number = ch.lib.icons.syntax.number,
  Null = ch.lib.icons.syntax.null,
  String = ch.lib.icons.syntax.string,
  Package = ch.lib.icons.syntax.package,
}

M.kind_icons = kind_icons

local kind_hl = {
  Text          = ch.lib.hl:get('syntax', 'text'),
  Method        = ch.lib.hl:get('syntax', 'method'),
  Function      = ch.lib.hl:get('syntax', 'fn'),
  Constructor   = ch.lib.hl:get('syntax', 'constructor'),
  Field         = ch.lib.hl:get('syntax', 'field'),
  Variable      = ch.lib.hl:get('syntax', 'variable'),
  Class         = ch.lib.hl:get('syntax', 'class'),
  Interface     = ch.lib.hl:get('syntax', 'interface'),
  Module        = ch.lib.hl:get('syntax', 'module'),
  Property      = ch.lib.hl:get('syntax', 'property'),
  Unit          = ch.lib.hl:get('syntax', 'unit'),
  Value         = ch.lib.hl:get('syntax', 'value'),
  Enum          = ch.lib.hl:get('syntax', 'enum'),
  Keyword       = ch.lib.hl:get('syntax', 'keyword'),
  Snippet       = ch.lib.hl:get('syntax', 'snippet'),
  Color         = ch.lib.hl:get('syntax', 'color'),
  File          = ch.lib.hl:get('syntax', 'file'),
  Reference     = ch.lib.hl:get('syntax', 'reference'),
  Folder        = ch.lib.hl:get('syntax', 'folder'),
  EnumMember    = ch.lib.hl:get('syntax', 'enummember'),
  Constant      = ch.lib.hl:get('syntax', 'constant'),
  Struct        = ch.lib.hl:get('syntax', 'struct'),
  Event         = ch.lib.hl:get('syntax', 'event'),
  Operator      = ch.lib.hl:get('syntax', 'operator'),
  TypeParameter = ch.lib.hl:get('syntax', 'typeparameter'),
  Namespace     = ch.lib.hl:get('syntax', 'namespace'),
  Table         = ch.lib.hl:get('syntax', 'table'),
  Object        = ch.lib.hl:get('syntax', 'object'),
  Tag           = ch.lib.hl:get('syntax', 'tag'),
  Array         = ch.lib.hl:get('syntax', 'array'),
  Boolean       = ch.lib.hl:get('syntax', 'boolean'),
  Number        = ch.lib.hl:get('syntax', 'number'),
  Null          = ch.lib.hl:get('syntax', 'null'),
  String        = ch.lib.hl:get('syntax', 'string'),
  Package       = ch.lib.hl:get('syntax', 'package'),
}

vim.iter(pairs(kind_hl)):each(function(kind, item)
  local hi_group = string.format('CmpItemKind%s', kind)
  ch.lib.hl.apply {
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
        vim_item.kind = ch.lib.fmt.space(kind_icons[kind])
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
