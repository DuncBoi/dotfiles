-- lua/autocmds.lua

local api = vim.api
local cmd = vim.cmd

local terminal_group = api.nvim_create_augroup("TerminalLocalOptions", { clear = true })

api.nvim_create_autocmd("TermOpen", {
  group = terminal_group,
  pattern = "*",
  callback = function()
    -- make it "nicer" (you might already have some of these)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.cursorline = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.statuscolumn = ""

    -- start in insert mode like a real terminal
    cmd("startinsert")
  end,
})

