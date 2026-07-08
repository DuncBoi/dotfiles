-- Shared toggle for Telescope-style pickers (harpoon menu, find_files) between
-- showing just the filename vs. the full path. Toggled with <C-f>.
local devicons = require("nvim-web-devicons")

local M = {}

M.show_full_paths = false

function M.shorten(path)
    return vim.fn.fnamemodify(path, ":t")
end

-- Drop-in `entry_maker` for `telescope.finders.new_table` / builtin pickers.
-- Prefixes the same devicons-based file icon Telescope's default entry maker uses.
function M.entry_maker(path)
    local filename = vim.fn.fnamemodify(path, ":t")
    local text = M.show_full_paths and path or filename
    local ext = filename:match("^.+%.(.+)$")
    local icon, icon_hl = devicons.get_icon(filename, ext, { default = true })
    icon = icon or ""

    return {
        value = path,
        ordinal = path,
        path = path,
        display = function()
            local line = icon .. " " .. text
            return line, { { { 0, #icon }, icon_hl or "TelescopeResultsIdentifier" } }
        end,
    }
end

function M.toggle()
    M.show_full_paths = not M.show_full_paths
end

-- Drop-in `attach_mappings` for pickers: binds <C-f> to toggle full/short paths
-- and refresh the current picker's results in place, live.
--
-- Telescope's static/job finders compute all entries once via entry_maker and
-- cache them forever, so refreshing with the *same* finder object is a no-op.
-- To actually re-render, we pull the raw paths back out of the current
-- (already-processed) entries and build a fresh finder with them.
function M.attach_mappings(prompt_bufnr, map)
    local action_state = require("telescope.actions.state")
    local finders = require("telescope.finders")

    local function toggle_and_refresh()
        M.toggle()
        local picker = action_state.get_current_picker(prompt_bufnr)

        local paths = {}
        for _, entry in ipairs(picker.finder.results) do
            table.insert(paths, entry.value)
        end

        local new_finder = finders.new_table({
            results = paths,
            entry_maker = M.entry_maker,
        })

        picker:refresh(new_finder, { reset_prompt = false })
    end

    map("i", "<C-f>", toggle_and_refresh)
    map("n", "<C-f>", toggle_and_refresh)
    return true
end

return M
