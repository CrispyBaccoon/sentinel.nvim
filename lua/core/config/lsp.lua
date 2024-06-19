local Util = require 'core.utils'

---@alias LspConfig__mappings 'show_lsp_info'|'open_float'|'goto_prev'|'goto_next'|'goto_declaration'|'goto_definition'|'peek_definition'|'hover'|'goto_implementation'|'show_signature'|'show_type_definition'|'rename'|'show_code_action'|'goto_references'|'format'
---@alias LspConfig__servers { [string]: { settings: table, [string]: table } }

---@class LspConfig__signature
---@field enabled boolean
---@field window { height: integer, width: integer, border: 'single'|'double'|'rounded'|'none' }

---@class LspConfigOpts
---@field mappings { [LspConfig__mappings]: string }
---@field signature LspConfig__signature
---@field diagnostic_lines core.types.diagnostic_lines.opts
---@field config table
---@field servers LspConfig__servers

---@param servers LspConfig__servers
---@param capabilities table
local function setup_servers(servers, capabilities)
  -- patch lua lsp
  if servers.lua_ls then
    -- Make runtime files discoverable to the server
    local runtime_path = vim.split(package.path, ';')
    table.insert(runtime_path, 'lua/?.lua')
    table.insert(runtime_path, 'lua/?/init.lua')
    servers.lua_ls.settings = {
      Lua = {
        diagnostics = {
          -- recognize 'vim' global
          globals = { 'vim', 'table', 'package' },
        },
        workspace = {
          -- Make server aware of nvim runtime files
          library = vim.api.nvim_get_runtime_file('', true),
        },
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT)
          version = 'LuaJIT',
          -- Setup your lua path
          path = runtime_path,
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = { enable = false },
      },
    }
  end

  local nvim_lsp = require 'lspconfig'

  for name, opts in pairs(servers) do
    if type(opts) == 'function' then
      opts = opts(nvim_lsp)
    end

    opts.capabilities = capabilities
    Util.log('lsp.setup', string.format('setup_lsp:%s', name))
    nvim_lsp[name].setup(opts)
  end
end

return {
  ---@param opts LspConfigOpts
  setup = function(opts)
    keymaps.normal[opts.mappings.show_lsp_info] = {
      function()
        require 'lspconfig.ui.lspinfo'()
      end,
      'Show Lsp Info',
    }

    -- lsp diagnostics
    vim.diagnostic.config(opts.config)

    -- Global mappings.
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    keymaps.normal[opts.mappings.open_float] =
      { vim.diagnostic.open_float, 'show diagnostics', group = 'LSP' }
    keymaps.normal[opts.mappings.goto_prev] =
      { vim.diagnostic.goto_prev, 'goto previous diagnostic', group = 'LSP' }
    keymaps.normal[opts.mappings.goto_next] =
      { vim.diagnostic.goto_next, 'goto next diagnostic', group = 'LSP' }

    core.lib.keymaps.register_qf_loader('lsp_diagnostics', function()
      vim.diagnostic.setqflist { open = false }
    end, { handle_open = true })

    -- nvim-cmp supports additional completion capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    require('core.plugins').load_plugins({ 'cmp-nvim-lua' })
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    Util.log('lsp.setup', 'set up lsp servers')
    setup_servers(opts.servers, capabilities)

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        Util.log('lsp.attach', 'lsp server attached to current buffer', 'info')

        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local map_opts = { buffer = ev.buf }
        keymaps.normal[opts.mappings.goto_declaration] = {
          vim.lsp.buf.declaration,
          'goto declaration',
          group = 'LSP',
          map_opts,
        }
        keymaps.normal[opts.mappings.goto_definition] = {
          vim.lsp.buf.definition,
          'goto definition',
          group = 'LSP',
          map_opts,
        }
        keymaps.normal[opts.mappings.peek_definition] = {
          function()
            require('core.plugin.lsp').peek_definition()
          end,
          'peek definition',
          group = 'LSP',
          map_opts,
        }
        keymaps.normal[opts.mappings.hover] =
          { vim.lsp.buf.hover, 'hover', group = 'LSP', map_opts }
        keymaps.normal[opts.mappings.goto_implementation] = {
          vim.lsp.buf.implementation,
          'goto implementation',
          group = 'LSP',
          map_opts,
        }
        keymaps.normal[opts.mappings.show_signature] = {
          vim.lsp.buf.signature_help,
          'show signature',
          group = 'LSP',
          map_opts,
        }
        keymaps.insert[opts.mappings.show_signature] = {
          vim.lsp.buf.signature_help,
          'show signature',
          group = 'LSP',
          map_opts,
        }
        keymaps.normal[opts.mappings.show_type_definition] = {
          vim.lsp.buf.type_definition,
          'show type definition',
          group = 'LSP',
          map_opts,
        }
        keymaps.normal[opts.mappings.rename] =
          { vim.lsp.buf.rename, 'rename', group = 'LSP', map_opts }
        keymaps.normal[opts.mappings.show_code_action] = {
          vim.lsp.buf.code_action,
          'show code action',
          group = 'LSP',
          map_opts,
        }
        keymaps.visual[opts.mappings.show_code_action] = {
          vim.lsp.buf.code_action,
          'show code action',
          group = 'LSP',
          map_opts,
        }
        keymaps.normal[opts.mappings.goto_references] = {
          vim.lsp.buf.references,
          'goto references',
          group = 'LSP',
          map_opts,
        }
        keymaps.normal[opts.mappings.format] = {
          function()
            vim.lsp.buf.format {
              async = true,
              filter = function(client)
                return client.name ~= 'null-ls'
              end,
            }
          end,
          'format',
          group = 'LSP',
          map_opts,
        }

        if opts.signature.enabled then
          vim.api.nvim_set_hl(
            0,
            'ActiveParameter',
            { link = 'LspSignatureActiveParameter' }
          )

          vim.api.nvim_create_autocmd('InsertLeave', {
            group = core.group_id,
            callback = require('core.plugin.lsp.signature').close_signature,
          })
          vim.api.nvim_create_autocmd({ 'InsertEnter', 'CursorMovedI' }, {
            group = core.group_id,
            callback = require('core.plugin.lsp.signature').auto_signature,
          })
        end

        if opts.diagnostic_lines.enabled then
          require 'core.plugin.lsp.diagnostic_lines'.setup(opts.diagnostic_lines)
        end
      end,
    })
  end,
}
