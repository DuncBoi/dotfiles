require("avante").setup({
    provider = "claude",
    behaviour = {
        auto_suggestions = false,
    },
    providers = {
        claude = {
            endpoint = "https://api.anthropic.com",
        },
    },
})
