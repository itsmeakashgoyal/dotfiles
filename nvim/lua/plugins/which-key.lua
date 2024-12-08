require("which-key").setup({
    preset = "helix",
    delay = 0,
    icons = {
        rules = false,
        breadcrumb = " ", -- symbol used in the command line area that shows your active key combo
        separator = "󱦰  ", -- symbol used between a key and it's label
        group = "󰹍 ", -- symbol prepended to a group
    },
    plugins = {
        spelling = {
            enabled = false,
        },
    },
    win = {
        height = {
            max = math.huge,
        },
    },
    spec = {
        {
            mode = { "n", "v" },
            -- { "<leader>G", group = "Git" },
            -- { "<leader>R", group = "Replace" },
            -- { "<leader>l", group = "LSP" },
            -- { "<leader>t", group = "Test" },
            -- { "<leader>s", group = "Search" },
            -- { "<leader>x", group = "diagnostics/quickfix" },
            -- { "<leader>n", group = "Gen Annotations" },
            -- { "<leader>N", group = "Package Info" },
            -- { "<leader>g", group = "Go" },
            -- { "<leader>W", group = "Workspace" },
            -- { "[", group = "prev" },
            -- { "]", group = "next" },
            -- { "g", group = "goto" },
        },
    },
})
