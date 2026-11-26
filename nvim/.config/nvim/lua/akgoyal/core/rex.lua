--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/core/rex.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Rex terminal: let Rex bring Neovim back after a restart.
-- When nvim runs inside Rex (which sets OSC7577_TOKEN), each saved session
-- (:mksession / :Sess) is reported as `nvim -S <file>` via Rex's Program Resume
-- Protocol. rex/.config/rex/init.lua trusts sessions saved under
-- ~/.local/state/nvim/sessions. Does nothing outside Rex.
-- Docs: https://www.superlogical.com/rex/docs/customize/resume-rules
local token = vim.env.OSC7577_TOKEN
if not token then
    return
end
vim.env.OSC7577_TOKEN = nil -- don't leak it to child processes

local dir = vim.fn.stdpath("state") .. "/sessions"

vim.api.nvim_create_autocmd("SessionWritePost", {
    callback = function()
        local argv = { "nvim", "-S", vim.v.this_session }
        for i, arg in ipairs(argv) do
            argv[i] = vim.base64.encode(arg)
        end
        -- This process is nvim's server; the terminal runs its parent (the TUI).
        local body = ("pid=%d:time=%d:argv=%s"):format(vim.uv.os_getppid(), os.time(), table.concat(argv, ","))
        local mac = vim.fn.sha256(body .. ":" .. token)
        io.stderr:write("\27]7577;", body, ":mac=", mac, "\27\\")
    end,
})

-- :Sess [name]  save a resumable session for this project (default: cwd name)
vim.api.nvim_create_user_command("Sess", function(opts)
    vim.fn.mkdir(dir, "p")
    local name = opts.args ~= "" and opts.args or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    vim.cmd("mksession! " .. vim.fn.fnameescape(dir .. "/" .. name .. ".vim"))
    vim.notify("Session saved; Rex will reopen it after a restart: " .. name)
end, { nargs = "?" })
