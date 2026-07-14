local harpoon = require("harpoon")
local path_display = require("duncvim.path_display")

harpoon:setup()

-- Multiple independent harpoon lists. List 1 is harpoon's original default
-- (nil name), so existing marks stay put; 2 and 3 start out as separate,
-- empty named lists. <leader>a, <C-e>, <C-h/j/k/l> always act on whichever
-- is active; switching/renaming only happens inside the harpoon picker
-- itself (<C-1>/<C-2>/<C-3>/<C-r>), and refreshes it live.
local list_names = { [1] = nil, [2] = "2", [3] = "3" }
local current_list_index = 1

local function current_list()
    return harpoon:list(list_names[current_list_index])
end

local function list_label(index)
    return list_names[index] or tostring(index)
end

-- Telescope-based fuzzy picker over harpoon marks, replacing the native quick menu.
local conf = require("telescope.config").values

local function current_harpoon_paths()
    local list = current_list()
    local paths = {}
    for i = 1, list._length do
        local item = list.items[i]
        if item then
            table.insert(paths, item.value)
        end
    end
    return paths
end

local function refresh_picker(prompt_bufnr)
    local action_state = require("telescope.actions.state")
    local finders = require("telescope.finders")
    local picker = action_state.get_current_picker(prompt_bufnr)

    local new_finder = finders.new_table({
        results = current_harpoon_paths(),
        entry_maker = path_display.entry_maker,
    })
    picker:refresh(new_finder, { reset_prompt = false })

    if picker.prompt_border and picker.prompt_border.change_title then
        picker.prompt_border:change_title("Harpoon " .. list_label(current_list_index))
    end
end

-- <C-f> (toggle full/short paths) comes from path_display.attach_mappings.
-- <C-d> here removes the currently selected mark and refreshes the list live.
local function attach_mappings(prompt_bufnr, map)
    path_display.attach_mappings(prompt_bufnr, map)

    local action_state = require("telescope.actions.state")

    local function delete_and_refresh()
        local entry = action_state.get_selected_entry()
        if not entry then
            return
        end
        current_list():remove({ value = entry.value })
        refresh_picker(prompt_bufnr)
    end

    local function switch_to_list(index)
        current_list_index = index
        refresh_picker(prompt_bufnr)
    end

    -- Renames the active list and moves its marks over to the new name
    -- (harpoon lists are keyed/persisted by name, so a bare reassignment
    -- would otherwise orphan the existing marks under the old name).
    local function rename_current_list()
        local new_name = vim.fn.input("Rename harpoon list " .. list_label(current_list_index) .. " to: ")
        if new_name == "" then
            return
        end

        local old_list = current_list()
        local items = old_list.items
        local length = old_list._length
        old_list:clear()

        list_names[current_list_index] = new_name
        local new_list = current_list()
        for i = 1, length do
            local item = items[i]
            if item then
                new_list:add(item)
            end
        end

        refresh_picker(prompt_bufnr)
    end

    map("i", "<C-d>", delete_and_refresh)
    map("n", "<C-d>", delete_and_refresh)
    -- Normal mode only, plain digits: Ctrl+1/2/3 aren't reliably sendable by
    -- terminals (Ctrl+3 is literally the same byte as Escape in the classic
    -- encoding), and binding plain digits in insert mode would break typing
    -- a search query.
    map("n", "1", function() switch_to_list(1) end)
    map("n", "2", function() switch_to_list(2) end)
    map("n", "3", function() switch_to_list(3) end)
    map("i", "<C-r>", rename_current_list)
    map("n", "<C-r>", rename_current_list)
    return true
end

local function toggle_telescope()
    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon " .. list_label(current_list_index),
        finder = require("telescope.finders").new_table({
            results = current_harpoon_paths(),
            entry_maker = path_display.entry_maker,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
        attach_mappings = attach_mappings,
    }):find()
end

vim.keymap.set("n", "<leader>a", function() current_list():add() end)
vim.keymap.set("n", "<C-e>", toggle_telescope, { desc = "Open harpoon window" })

vim.keymap.set("n", "<C-h>", function() current_list():select(1) end)
vim.keymap.set("n", "<C-j>", function() current_list():select(2) end)
vim.keymap.set("n", "<C-k>", function() current_list():select(3) end)
vim.keymap.set("n", "<C-l>", function() current_list():select(4) end)
