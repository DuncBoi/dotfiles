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

-- Swift: sourcekit-lsp ships with Xcode, so it's not Mason-managed like the
-- servers above. Uses the newer native vim.lsp API (nvim-lspconfig's
-- require('lspconfig')[x].setup{} is deprecated as of Neovim 0.11).
vim.lsp.enable('sourcekit')

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

    -- Jumps straight there for a single definition; opens the same
    -- fuzzy-list-with-preview UI as <leader>gc/<leader>ff when there are
    -- multiple, instead of the default quickfix-list-based vim.lsp.buf.definition().
    vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    -- Find all callers/usages of the symbol under the cursor, via Telescope
    -- (same fuzzy-list-with-preview UI as <leader>ff/<leader>fs) instead of
    -- the default quickfix-list-based vim.lsp.buf.references().
    vim.keymap.set("n", "<leader>gc", require("telescope.builtin").lsp_references, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
end)

-- optional nicer diagnostics
vim.diagnostic.config({
    virtual_text = true
})
