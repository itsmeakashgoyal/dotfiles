--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/showkeys.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Showkeys: displays recently pressed keys on screen, toggled via command.
return {
    {
        "nvzone/showkeys",
        cmd = "ShowkeysToggle",
        opts = {
            -- position = "bottom-right",
            maxkeys = 3,
            show_count = true,
            winopts = {
                focusable = false,
                relative = "editor",
                style = "minimal",
                border = "single",
                height = 1,
                row = 1,
                col = 0,
            },
        },
    },
}
