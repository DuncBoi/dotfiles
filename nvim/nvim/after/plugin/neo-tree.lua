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
            -- Disable the default g-prefixed git commands (unused) so plain
            -- "g" below is unambiguous and fires with no wait. "noop" tells
            -- neo-tree to skip registering the keymap entirely — unlike an
            -- empty function, which would still be a real (if useless)
            -- registered mapping and keep "g" ambiguous.
            ["gu"] = "noop",
            ["gU"] = "noop",
            ["ga"] = "noop",
            ["gt"] = "noop",
            ["gr"] = "noop",
            ["gc"] = "noop",
            ["gp"] = "noop",
            ["gg"] = "noop",
            -- Toggle between filesystem and git_status views with the same key.
            -- Remembers the last source (vim.g.neotree_last_source) so
            -- <leader>e reopens on whichever view you were last on.
            ["g"] = function(state)
                local target = state.name == "git_status" and "filesystem" or "git_status"
                vim.g.neotree_last_source = target
                require("neo-tree.command").execute({
                    source = target,
                    position = state.current_position,
                    action = "focus",
                })
            end,
        },
    },
    default_component_configs = {
        indent = {
            with_expanders = true,
        },
    },
})

