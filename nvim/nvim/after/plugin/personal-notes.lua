-- Personal notes: never sent anywhere, never read by any hook — just a
-- plain per-repo log you write to and browse yourself. Separate on purpose
-- from claude-notes.lua (that one's piped to Claude; this one is not).
local function repo_root()
    local dir = vim.fn.expand("%:p:h")
    if dir == "" then
        dir = vim.fn.getcwd()
    end
    local root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel")[1]
    return root
end

local function notes_file_for(root)
    local safe_repo = root:gsub("[^%w]", "_")
    local notes_dir = vim.fn.expand("~/.local/share/nvim/notes")
    vim.fn.mkdir(notes_dir, "p")
    return notes_dir .. "/" .. safe_repo .. ".log"
end

local function write_personal_note(root, rel_path, line, text)
    local f = io.open(notes_file_for(root), "a")
    if f then
        f:write(rel_path .. ":" .. line .. ": " .. text .. "\n")
        f:close()
        print("Note saved: " .. rel_path .. ":" .. line)
    else
        print("personal-notes: failed to write note")
    end
end

-- Persistent inline markers: whenever a buffer is opened (or right after
-- saving a note in it), place a sign + virtual text on every line that has
-- a saved note, read fresh from the notes file each time.
local marker_ns = vim.api.nvim_create_namespace("personal_notes_markers")

local function refresh_markers_for_current_buffer()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(buf, marker_ns, 0, -1)

    local root = repo_root()
    if not root or root == "" then
        return
    end
    local file = vim.fn.expand("%:p")
    if file == "" then
        return
    end
    local rel_path = file:sub(#root + 2)

    local f = io.open(notes_file_for(root), "r")
    if not f then
        return
    end
    for l in f:lines() do
        local path, lnum, text = l:match("^([^:]+):(%d+):%s?(.*)$")
        if path == rel_path then
            local row = tonumber(lnum) - 1
            if row >= 0 and row < vim.api.nvim_buf_line_count(buf) then
                -- A boxed line right below the annotated one, tuicr-style,
                -- instead of plain end-of-line text.
                vim.api.nvim_buf_set_extmark(buf, marker_ns, row, 0, {
                    sign_text = "»",
                    sign_hl_group = "PersonalNoteSign",
                    virt_lines = { { { "  ┃ " .. text, "PersonalNoteVirtText" } } },
                })
            end
        end
    end
    f:close()
end

local function refresh_markers_everywhere()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        vim.api.nvim_win_call(win, refresh_markers_for_current_buffer)
    end
end

vim.api.nvim_set_hl(0, "PersonalNoteSign", { link = "DiagnosticSignHint" })
vim.api.nvim_set_hl(0, "PersonalNoteVirtText", { link = "Comment" })

vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
    callback = refresh_markers_for_current_buffer,
})

local function open_note_float(root, rel_path, line)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor",
        row = 1,
        col = 0,
        width = 60,
        height = 1,
        style = "minimal",
        border = "rounded",
        title = " New Note (Enter: save · Esc: cancel) ",
        title_pos = "center",
    })
    vim.wo[win].winhl = "Normal:NormalFloat"

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    local function submit()
        local text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), " "))
        close()
        if text ~= "" then
            write_personal_note(root, rel_path, line, text)
            refresh_markers_for_current_buffer()
        end
    end

    vim.keymap.set({ "i", "n" }, "<CR>", submit, { buffer = buf })
    vim.keymap.set({ "i", "n" }, "<Esc>", close, { buffer = buf })

    vim.cmd("startinsert")
end

local function new_note()
    local root = repo_root()
    if not root or root == "" then
        print("personal-notes: not in a git repo")
        return
    end

    local file = vim.fn.expand("%:p")
    local rel_path = file ~= "" and file:sub(#root + 2) or "(no file)"
    local line = vim.fn.line(".")

    open_note_float(root, rel_path, line)
end

-- Toggleable panel listing every saved note for the current repo. <CR> on
-- an entry jumps straight to that file:line. Same key closes it again.
local panel_buf = nil
local panel_win = nil

local function close_panel()
    if panel_win and vim.api.nvim_win_is_valid(panel_win) then
        vim.api.nvim_win_close(panel_win, true)
    end
    panel_win = nil
    panel_buf = nil
end

local HEADER = "── Personal Notes (<CR> jump · x delete · q/Esc close) ──"

local function open_panel(root)
    local notes_file = notes_file_for(root)

    local function read_entries()
        local entries = {}
        local f = io.open(notes_file, "r")
        if f then
            for l in f:lines() do
                if l ~= "" then
                    table.insert(entries, l)
                end
            end
            f:close()
        end
        return entries
    end

    local function render(entries)
        local lines = { HEADER }
        if #entries == 0 then
            table.insert(lines, "(no notes yet for this repo — <leader>n to add one)")
        else
            for _, l in ipairs(entries) do
                table.insert(lines, l)
            end
        end
        vim.bo[panel_buf].modifiable = true
        vim.api.nvim_buf_set_lines(panel_buf, 0, -1, false, lines)
        vim.bo[panel_buf].modifiable = false
        if panel_win and vim.api.nvim_win_is_valid(panel_win) then
            vim.api.nvim_win_set_height(panel_win, math.min(#lines + 1, 14))
        end
    end

    local function jump_to_note_entry()
        local line_text = vim.api.nvim_get_current_line()
        local path, lnum = line_text:match("^([^:]+):(%d+):")
        if not path then
            return
        end
        close_panel()
        vim.cmd("edit +" .. lnum .. " " .. vim.fn.fnameescape(root .. "/" .. path))
    end

    local function delete_note_entry()
        local line_text = vim.api.nvim_get_current_line()
        if not line_text:match("^[^:]+:%d+:") then
            return -- header or placeholder line, nothing to delete
        end
        local entries = read_entries()
        local remaining = {}
        for _, l in ipairs(entries) do
            if l ~= line_text then
                table.insert(remaining, l)
            end
        end
        local out = io.open(notes_file, "w")
        if out then
            for _, l in ipairs(remaining) do
                out:write(l .. "\n")
            end
            out:close()
        end
        render(remaining)
        refresh_markers_everywhere()
    end

    panel_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[panel_buf].buftype = "nofile"
    vim.bo[panel_buf].bufhidden = "wipe"
    vim.bo[panel_buf].filetype = "personal-notes"

    vim.cmd("botright split")
    panel_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(panel_win, panel_buf)
    vim.wo[panel_win].number = false
    vim.wo[panel_win].relativenumber = false

    render(read_entries())

    vim.keymap.set("n", "<CR>", jump_to_note_entry, { buffer = panel_buf })
    vim.keymap.set("n", "x", delete_note_entry, { buffer = panel_buf })
    vim.keymap.set("n", "q", close_panel, { buffer = panel_buf })
    vim.keymap.set("n", "<Esc>", close_panel, { buffer = panel_buf })
end

local function toggle_notes_panel()
    if panel_win and vim.api.nvim_win_is_valid(panel_win) then
        close_panel()
        return
    end
    local root = repo_root()
    if not root or root == "" then
        print("personal-notes: not in a git repo")
        return
    end
    open_panel(root)
end

vim.keymap.set("n", "<leader>n", new_note, { desc = "Add a personal note at this line" })
vim.keymap.set("n", "<leader>N", toggle_notes_panel, { desc = "Toggle personal notes panel" })
