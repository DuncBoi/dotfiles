require("gitsigns").setup({
    on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local opts = { buffer = bufnr }

        vim.keymap.set("n", "]c", gitsigns.next_hunk, opts)
        vim.keymap.set("n", "[c", gitsigns.prev_hunk, opts)
        vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, opts)
        vim.keymap.set("n", "<leader>hd", gitsigns.diffthis, opts)
        vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, opts)
        vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, opts)
    end,
})
