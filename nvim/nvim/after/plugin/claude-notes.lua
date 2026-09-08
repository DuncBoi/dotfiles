-- Leave a quick note for Claude at the current line. Appends
-- "path:line: text" to a plain log file per repo under ~/.claude/claude-notes/
-- — no review-session/PR structure, just a flat line Claude's Stop hook tails.
local function write_note(rel_path, line, text)
    local repo_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    local safe_repo = repo_root:gsub("[^%w]", "_")
    local notes_dir = vim.fn.expand("~/.claude/claude-notes")
    vim.fn.mkdir(notes_dir, "p")
    local notes_file = notes_dir .. "/" .. safe_repo .. ".log"

    local f = io.open(notes_file, "a")
    if f then
        f:write(rel_path .. ":" .. line .. ": " .. text .. "\n")
        f:close()
        print("Note added for Claude: " .. rel_path .. ":" .. line)
    else
        print("claude-notes: failed to write note")
    end
end

-- Small floating input box (rounded border, title showing file:line) instead
-- of a bottom command-line prompt.
-- Claude's brand clay/orange, used for the float's border.
vim.api.nvim_set_hl(0, "ClaudeNoteBorder", { fg = "#D97757" })

local function open_note_float(rel_path, line)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"

    local width = 60
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor",
        row = 1,
        col = 0,
        width = width,
        height = 1,
        style = "minimal",
        border = "rounded",
        title = " Ask Claude ",
        title_pos = "center",
    })
    vim.wo[win].winhl = "Normal:NormalFloat,FloatBorder:ClaudeNoteBorder"

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    local function submit()
        local text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), " "))
        close()
        if text ~= "" then
            write_note(rel_path, line, text)
        end
    end

    vim.keymap.set({ "i", "n" }, "<CR>", submit, { buffer = buf })
    vim.keymap.set({ "i", "n" }, "<Esc>", close, { buffer = buf })

    vim.cmd("startinsert")
end

local function claude_note()
    local file = vim.fn.expand("%:p")
    if file == "" then
        return
    end

    local dir = vim.fn.expand("%:p:h")
    local repo_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel")[1]
    if not repo_root or repo_root == "" then
        print("claude-notes: not in a git repo")
        return
    end

    local rel_path = file:sub(#repo_root + 2)
    local line = vim.fn.line(".")

    open_note_float(rel_path, line)
end

vim.keymap.set("n", "<leader>c", claude_note, { desc = "Leave a note for Claude at this line" })
