require("neo-tree").setup({
    filesystem = {
        hijack_netrw_behavior = "disabled",
        follow_current_file = { enabled = true }, -- auto jump to current file
        filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
        },
    },
    window = {
        mappings = {
            ["C"] = "set_root",     -- make folder under cursor the new root
            ["U"] = "navigate_up",  -- go up to parent directory
        },
    }, 
    default_component_configs = {
        indent = {
            with_expanders = true,
        },
    },
})

