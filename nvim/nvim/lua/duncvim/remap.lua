vim.g.mapleader = " " -- Use space as the leader key
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- terminal stuff
local term_height = 12
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>t", function()
  vim.cmd(("belowright %dsplit | terminal"):format(term_height))
end, { desc = "Open terminal in bottom split" })
vim.keymap.set("n", "<leader>T", function()
  vim.cmd("vsplit | terminal")
end, { desc = "Open terminal (right)" })

vim.keymap.set({ "n", "i", "t", "v" }, "<C-q>", function()
  vim.cmd("stopinsert")
  pcall(vim.api.nvim_win_close, 0, false)
end, { desc = "Close current window" })

-- neo-tree
-- Plain ":Neotree toggle filesystem" only checks the filesystem source's own
-- window state, so if the tree is open on a different source (e.g. git
-- status via "g"), it switches to filesystem instead of closing. This closes
-- whatever's open at the left position regardless of source, or reopens on
-- whichever source was last used (tracked in vim.g.neotree_last_source by
-- the "g" mapping in neo-tree.lua), defaulting to filesystem.
local function neotree_left_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      return true
    end
  end
  return false
end

vim.keymap.set("n", "<leader>e", function()
  if neotree_left_open() then
    require("neo-tree.command").execute({ action = "close", position = "left" })
  else
    local source = vim.g.neotree_last_source or "filesystem"
    require("neo-tree.command").execute({ source = source, position = "left", action = "show" })
  end
end, {
  desc = "Toggle Neo-tree file explorer",
  silent = true,
})

-- window navigation
vim.keymap.set("n", "<leader>h", "<C-w>h", { silent = true, desc = "Focus left split" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { silent = true, desc = "Focus right split" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { silent = true, desc = "Focus down split" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { silent = true, desc = "Focus up split" })

vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Horizontal scroll (half a screen width at a time). Replaces the default
-- H/L (jump cursor to top/bottom of screen) since Ctrl+Arrow gets eaten by
-- macOS's Mission Control space-switching shortcut before it reaches the
-- terminal at all.
vim.keymap.set("n", "H", "zH", { desc = "Scroll view left" })
vim.keymap.set("n", "L", "zL", { desc = "Scroll view right" })

-- Delete always goes to the black hole register instead of the unnamed one,
-- so it never clobbers whatever you last yanked with `y` (still pasteable via `p`).
vim.keymap.set({ "n", "v" }, "d", [["_d]])
vim.keymap.set({ "n", "v" }, "D", [["_D]])
vim.keymap.set({ "n", "v" }, "x", [["_x]])
vim.keymap.set({ "n", "v" }, "X", [["_X]])
