local builtin = require("telescope.builtin")
local path_display = require("duncvim.path_display")

vim.keymap.set("n", "<leader>ff", function()
    builtin.find_files({
        entry_maker = path_display.entry_maker,
        attach_mappings = path_display.attach_mappings,
    })
end)
vim.keymap.set("n", "<C-p>",       builtin.git_files)
vim.keymap.set("n", "<leader>fs", function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
