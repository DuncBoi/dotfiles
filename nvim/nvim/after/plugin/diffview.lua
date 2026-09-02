local actions = require("diffview.actions")

-- q closes the whole diffview session from any of its windows; <C-u>/<C-d>
-- scroll the diff view instead of the default <C-b>/<C-f>.
local function close()
    vim.cmd("DiffviewClose")
end

local noop = function() end

local function replace_scroll()
    return {
        { "n", "q", close, { desc = "Close Diffview" } },
        { "n", "<c-b>", noop },
        { "n", "<c-f>", noop },
        { "n", "<c-u>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
        { "n", "<c-d>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
    }
end

require("diffview").setup({
    keymaps = {
        view = { { "n", "q", close, { desc = "Close Diffview" } } },
        file_panel = replace_scroll(),
        file_history_panel = replace_scroll(),
    },
})

-- File history for the current file; in visual mode, scoped to the selected line range.
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>")
vim.keymap.set("v", "<leader>gh", "<esc><cmd>'<,'>DiffviewFileHistory<CR>")

-- Every changed file (staged + unstaged) vs the last commit, whole repo.
vim.keymap.set("n", "<leader>hd", "<cmd>DiffviewOpen HEAD<CR>")
