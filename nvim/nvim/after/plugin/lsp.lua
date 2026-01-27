-- after/plugin/lsp.lua

local lsp_zero = require('lsp-zero')

-- mason: install language servers
require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {
        'lua_ls',
        'clangd',
        'pyright',
        'ts_ls',
        'html',
        'cssls',
    },
    handlers = {
        function(server)
            local opts = {}

            -- special config for lua
            if server == 'lua_ls' then
                opts.settings = {
                    Lua = {
                        diagnostics = { globals = {'vim'} }
                    }
                }
            end

            require('lspconfig')[server].setup(opts)
        end,
    }
})

-- completion setup (nvim-cmp)
local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
    mapping = {
        ['<C-j>'] = cmp.mapping.select_next_item(),
        ['<C-k>'] = cmp.mapping.select_prev_item(),
        ['<CR>'] = cmp.mapping.confirm({select = true}),
        ['<C-Space>'] = cmp.mapping.complete(),
    },
    sources = {
        {name = 'nvim_lsp'},
        {name = 'buffer'},
        {name = 'path'},
    }
})

-- keymaps applied when LSP attaches to a buffer
lsp_zero.on_attach(function(_, bufnr)
    local opts = {buffer = bufnr}

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
end)

-- optional nicer diagnostics
vim.diagnostic.config({
    virtual_text = true
})
