local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local path_display = require("duncvim.path_display")

-- override_*_sorter is what extends the fzf query syntax to *every* picker,
-- not just the file finder.
telescope.setup({
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
})
telescope.load_extension("fzf")

vim.keymap.set("n", "<leader>ff", function()
    builtin.find_files({
        entry_maker = path_display.entry_maker,
        attach_mappings = path_display.attach_mappings,
    })
end)
vim.keymap.set("n", "<C-p>",       builtin.git_files)
vim.keymap.set("n", "<leader>fs", builtin.live_grep)

-- Translate an fzf-native prompt query into the closest vim search pattern, so
-- n/N still work after selecting. fzf's operators have no vim equivalent, so:
-- negated terms are dropped (vim search can't express "not"), the exact-match
-- quote is stripped, ^/$ anchors are kept (same meaning in both), regex
-- metacharacters are escaped (fzf treats them literally), and the surviving
-- terms are OR'd — fzf ANDs them, but OR is the useful approximation for n/N.
local function fzf_query_to_vim_pattern(query)
    local branches = {}
    for term in query:gmatch("%S+") do
        if term ~= "|" and not term:match("^!") then
            term = term:gsub("^'", "")
            local prefix, suffix = "", ""
            if term:match("^%^") then
                prefix, term = "^", term:sub(2)
            end
            if term:match("%$$") then
                suffix, term = "$", term:sub(1, -2)
            end
            if term ~= "" then
                table.insert(branches, prefix .. vim.fn.escape(term, "\\/.*$^~[]") .. suffix)
            end
        end
    end
    return table.concat(branches, "\\|")
end

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
                        local pattern = fzf_query_to_vim_pattern(captured_prompt)
                        if pattern ~= "" then
                            vim.fn.setreg("/", pattern)
                        end
                    end
                end,
            })
            return true
        end,
    })
end)
