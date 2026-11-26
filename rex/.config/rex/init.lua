--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ rex/.config/rex/init.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Rex (https://www.superlogical.com/rex/docs): terminal + multiplexer. Used
-- alongside iTerm2 (+ tmux), which stay set up as before.
--
-- Inside Rex, Rex is the multiplexer (don't start tmux), with the same keys
-- as tmux.conf: ⌃a then a key. Rex's own ⌘ shortcuts also work (⌘D split,
-- ⌘K sessions, ⌘P go to anything, ⇧⌘P command palette, ⇧⌘C copy mode).
--
-- After editing:  rex config check   then   rex config reload
-- (Rex doesn't watch this file.) `rex keymap` shows what's loaded.

local P = "ctrl+a>"   -- tmux prefix (tmux.conf: set -g prefix C-a)

-- ── tmux-style keys ──────────────────────────────────────────────────────────
rex.bind(P .. "ctrl+a", "pane.send_key", { key = "ctrl+a" })  -- ⌃a ⌃a = line start in zsh

-- Splits (keep the current directory, like tmux's -c "#{pane_current_path}")
rex.bind(P .. "shift+\\", "pane.split", { direction = "right" })  -- |
rex.bind(P .. "\\",       "pane.split", { direction = "right" })
rex.bind(P .. "-",        "pane.split", { direction = "down" })
rex.bind(P .. "shift+-",  "pane.split", { direction = "down" })   -- _

-- Move between panes; resize with the `resize` mode below
rex.bind(P .. "h", "pane.focus.left")
rex.bind(P .. "j", "pane.focus.down")
rex.bind(P .. "k", "pane.focus.up")
rex.bind(P .. "l", "pane.focus.right")
rex.bind(P .. "z", "pane.zoom")
rex.bind(P .. "x", "pane.close")
rex.bind(P .. "shift+b", "pane.move_to_new_tab")   -- tmux break-pane
rex.bind(P .. "=", "pane.balance")

-- Tabs (tmux windows)
rex.bind(P .. "c", "client.tab.new")
rex.bind(P .. "n", "client.tab.next")
rex.bind(P .. "p", "client.tab.previous")
rex.bind(P .. ",", "client.tab.rename")
for i = 1, 9 do
  rex.bind(P .. tostring(i), "client.tab.goto", { index = i })
end

-- Sessions
rex.bind(P .. "s", "session.switch")
rex.bind(P .. "b", "session.previous")
rex.bind(P .. "shift+4", "session.rename")       -- $
rex.bind(P .. "shift+n", "session.new")

-- Copy mode (vi keys inside: v / V / ⌃v select, y copy, / search, q quit)
rex.bind(P .. "[", "pane.copy_mode.enter")

-- Find, go to anything, palette
rex.bind(P .. "/", "client.find.open")
rex.bind(P .. "w", "pane.go_to")
rex.bind(P .. "shift+;", "client.palette.toggle")   -- :

-- ── Resize mode: ⌃a r, then h/j/k/l (shift = bigger), = balance, Esc/Enter leave
rex.mode("resize", { exclusive = true })
rex.bind(P .. "r", "client.mode.enter", { name = "resize" })
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("resize/" .. key, "pane.resize", { direction = dir })
  rex.bind("resize/shift+" .. key, "pane.resize", { direction = dir, amount = 15 })
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")

-- ── Project jumper (same repos as `p` / ⌃G / tmux prefix f) ─────────────────
-- Pick a git repo; switch to its session, or create one there.
local HOME = os.getenv("HOME")
local SHELL = "com.superlogical.terminal.shell"

rex.action{
  name     = "project",
  title    = "Open Project…",
  category = "Projects",
  keywords = "repo git project jump workspace",
  run = function(ctx, args)
    local r, err = rex.exec({ HOME .. "/.local/bin/proj", "--list" }, {
      timeout = 15,
      env = { PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:" .. HOME .. "/.local/bin" },
    })
    if r == nil then error(err, 0) end
    if not r.ok then error("proj --list failed: " .. r.stderr, 0) end

    local items = {}
    for line in r.stdout:gmatch("[^\n]+") do
      local name = line:match("([^/]+)$")
      items[#items + 1] = { id = line, title = name, subtitle = line, icon = "folder" }
    end
    local pick = rex.ui.pick{
      title = "Open project", placeholder = "Filter repos", items = items,
    }
    if pick == nil then return end
    local dir = pick:gsub("^~", HOME)
    local label = dir:match("([^/]+)$")

    local list = rex.call("session.list")
    for _, s in ipairs((list and list.sessions) or {}) do
      if s.label == label then
        rex.client.queue("session.select", { session_id = s.session_id })
        return
      end
    end
    local s, cerr = rex.call("session.create", {
      label = label,
      initial_windows = { {
        layout = rex.layout.block{ flavor = SHELL, options = { cwd = dir } },
      } },
    })
    if s == nil then error(cerr, 0) end
    rex.client.queue("session.select", { session_id = s.session_id })
  end,
}
rex.bind(P .. "f", "project")
rex.bind("shift+cmd+o", "project")

-- ── Dotfiles helpers ─────────────────────────────────────────────────────────
rex.action{
  name     = "dotfiles",
  title    = "Open Dotfiles Session",
  category = "Projects",
  run = function(ctx, args)
    local dir = HOME .. "/dotfiles"
    local list = rex.call("session.list")
    for _, s in ipairs((list and list.sessions) or {}) do
      if s.label == "dotfiles" then
        rex.client.queue("session.select", { session_id = s.session_id })
        return
      end
    end
    local s, err = rex.call("session.create", {
      label = "dotfiles",
      initial_windows = { {
        layout = rex.layout.block{ flavor = SHELL, options = { cwd = dir } },
      } },
    })
    if s == nil then error(err, 0) end
    rex.client.queue("session.select", { session_id = s.session_id })
  end,
}

-- ── Resume rules (what comes back after a restart) ───────────────────────────
-- Built in: Claude Code, Codex, OpenCode. Also resume Neovim sessions saved
-- with :mksession under ~/.local/state/nvim/sessions (nvim reports them; see
-- nvim/.config/nvim/lua/akgoyal/core/rex.lua).
rex.set("resume.trust.nvim", {
  command = { "nvim", "-S", rex.match.under("~/.local/state/nvim/sessions") },
})
