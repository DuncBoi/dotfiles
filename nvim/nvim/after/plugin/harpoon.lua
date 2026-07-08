local harpoon = require("harpoon")
local path_display = require("duncvim.path_display")

harpoon:setup()

-- Telescope-based fuzzy picker over harpoon marks, replacing the native quick menu.
local conf = require("telescope.config").values

local function current_harpoon_paths()
    local list = harpoon:list()
    local paths = {}
    for i = 1, list._length do
        local item = list.items[i]
        if item then
            table.insert(paths, item.value)
        end
    end
    return paths
end

-- <C-f> (toggle full/short paths) comes from path_display.attach_mappings.
-- <C-d> here removes the currently selected mark and refreshes the list live.
local function attach_mappings(prompt_bufnr, map)
    path_display.attach_mappings(prompt_bufnr, map)

    local action_state = require("telescope.actions.state")
    local finders = require("telescope.finders")

    local function delete_and_refresh()
        local entry = action_state.get_selected_entry()
        if not entry then
            return
        end
        harpoon:list():remove({ value = entry.value })

        local picker = action_state.get_current_picker(prompt_bufnr)
        local new_finder = finders.new_table({
            results = current_harpoon_paths(),
            entry_maker = path_display.entry_maker,
        })
        picker:refresh(new_finder, { reset_prompt = false })
    end

    map("i", "<C-d>", delete_and_refresh)
    map("n", "<C-d>", delete_and_refresh)
    return true
end

local function toggle_telescope()
    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = current_harpoon_paths(),
            entry_maker = path_display.entry_maker,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
        attach_mappings = attach_mappings,
    }):find()
end

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", toggle_telescope, { desc = "Open harpoon window" })

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end)
