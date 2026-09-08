require("gitsigns").setup({
    numhl = true,
    word_diff = true,
    on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local opts = { buffer = bufnr }

        vim.keymap.set("n", "]c", gitsigns.next_hunk, opts)
        vim.keymap.set("n", "[c", gitsigns.prev_hunk, opts)
        vim.keymap.set("n", "<leader>dp", gitsigns.preview_hunk, opts)
        vim.keymap.set("n", "<leader>ds", gitsigns.stage_hunk, opts)
        vim.keymap.set("n", "<leader>dr", gitsigns.reset_hunk, opts)
    end,
})
