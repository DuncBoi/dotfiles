-- after/plugin/treesitter.lua

require'nvim-treesitter'.setup{
  ensure_installed = {
    "c",
    "cpp",
    "lua",
    "vim",
    "query",
    "javascript",
    "typescript",
    "tsx",
    "python",
    "jsx",
    "html",
    "css",
  },
  sync_install = false,
  auto_install = true,

  highlight = { enable = true },
  indent = { enable = true },
}
