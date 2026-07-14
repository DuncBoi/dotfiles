local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local path_display = require("duncvim.path_display")

vim.keymap.set("n", "<leader>ff", function()
    builtin.find_files({
        entry_maker = path_display.entry_maker,
        attach_mappings = path_display.attach_mappings,
    })
end)
vim.keymap.set("n", "<C-p>",       builtin.git_files)
vim.keymap.set("n", "<leader>fs", builtin.live_grep)

-- fuzzy search within the current buffer, in place of native `/`
-- keeps n/N working afterwards by pushing the query into the search register
vim.keymap.set("n", "/", function()
    builtin.current_buffer_fuzzy_find({
        attach_mappings = function(prompt_bufnr, map)
            local captured_prompt
            actions.select_default:enhance({
                pre = function()
                    captured_prompt = action_state.get_current_line()
                end,
                post = function()
                    if captured_prompt and captured_prompt ~= "" then
                        vim.fn.setreg("/", captured_prompt)
                    end
                end,
            })
            return true
        end,
    })
end)
