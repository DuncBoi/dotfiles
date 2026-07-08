require("avante").setup({
    provider = "claude",
    behaviour = {
        auto_suggestions = false,
    },
    highlights = {
        diff = {
            current = "DiffText",
            incoming = "DiffAdd",
        },
    },
    providers = {
        claude = {
            endpoint = "https://api.anthropic.com",
            api_key_name = "ANTHROPIC_API_KEY",
        },
    },
})
