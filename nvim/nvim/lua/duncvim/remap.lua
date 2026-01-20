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
vim.keymap.set("n", "<leader>e", ":Neotree toggle filesystem left<CR>", {
  desc = "Toggle Neo-tree file explorer",
  silent = true,
})

-- window navigation
vim.keymap.set("n", "<leader>h", "<C-w>h", { silent = true, desc = "Focus left split" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { silent = true, desc = "Focus right split" })
vim.keymap.set("n", "<leader>j", "<C-w>j", { silent = true, desc = "Focus down split" })
vim.keymap.set("n", "<leader>k", "<C-w>k", { silent = true, desc = "Focus up split" })

--codex
vim.keymap.set("n", "<leader>cc", function()
  require("codex").toggle()
end, { desc = "Toggle Codex" })

vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

