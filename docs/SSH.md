# Git identities & SSH keys

One command sets up personal **and** any number of work/company GitHub accounts
on macOS, Linux and Windows:

```bash
dutils git-setup          # wizard: personal profile, then "add a work profile?"
```

After that you clone with the **normal URL from GitHub's copy button** and each
repo picks the right email, SSH key and (optionally) commit signing by itself.
There are no special host aliases to remember.

```text
git clone git@github.com:acme/app.git        → work identity + work key   (org rule)
git clone git@github.acme.com:team/svc.git   → work identity + work key   (enterprise host rule)
git clone git@github.com:you/dotfiles.git    → personal identity + key    (your username is a personal "org")
cd ~/work && git init scratch                → work identity              (folder rule)
anything else                                → the machine's default profile
```

## Where things live

Nothing machine-specific is in the repo. The tracked `git/.config/git/config`
has **no** `user.email`: it sets `user.useConfigOnly = true` (git refuses to
commit rather than guess) and includes a per-machine file:

| File | What |
|---|---|
| `~/.config/dotfiles/git/profiles.json` | Source of truth, written by `dutils git-setup` |
| `~/.config/dotfiles/git/config` | Generated: default identity + `includeIf` rules + URL rewrites |
| `~/.config/dotfiles/git/<profile>.gitconfig` | Generated: name, email, `core.sshCommand`, signing |
| `~/.config/dotfiles/git/allowed_signers` | Generated when signing is on (`git log --show-signature`) |
| `~/.ssh/config.d/dotfiles` | Generated `Host` blocks, `Include`d at the top of `~/.ssh/config` |

Re-running is always safe. `dutils git-setup apply` regenerates everything from
`profiles.json`; your own `~/.ssh/config` content is left untouched.

## A profile

```json
"work": {
  "name": "Your Name",
  "email": "you@acme.com",
  "orgs": ["acme", "acme-labs"],          // GitHub orgs on github.com
  "hosts": ["github.acme.com"],           // GitHub Enterprise hosts
  "dirs": ["~/work/"],                    // folders whose repos are always work
  "aliases": ["github-work"],             // ssh alias (also matched as a remote)
  "key": "~/.ssh/id_ed25519_work",
  "sign": true                            // SSH-sign commits and tags
}
```

How a repo resolves (later wins): **default profile < folder rules < remote
rules**. So a personal repo cloned inside `~/work/` still commits as personal.

How the key is chosen:

- SSH URLs for a non-default profile's orgs are rewritten to its alias
  (`url.<alias>.insteadOf`), so `git clone` already uses the right key.
- Enterprise hosts get their own `Host` block with the profile's key.
- Every repo that resolves to a profile pins its key via `core.sshCommand`.
- Plain `github.com` uses the default profile's key.

## Commands

```bash
dutils git-setup                     # wizard (first run), or menu to add/edit/remove
dutils git-setup status [PATH]       # profiles + which identity PATH (default: cwd) gets
dutils git-setup add acme            # add/update a profile interactively
dutils git-setup add acme -y --email you@acme.com --org acme \
    --host github.acme.com --dir ~/work --sign    # …or non-interactively
dutils git-setup default personal    # change this machine's default
dutils git-setup remove acme
dutils git-setup test                # ssh -T every profile: "Hi <user>!"
dutils git-setup apply               # regenerate from profiles.json
git whoami                           # name <email> for the current repo
```

The wizard lets you pick an existing key in `~/.ssh` or generate a new ed25519
key. It copies the public key to the clipboard; add it at
<https://github.com/settings/keys> (as an *Authentication* key, and also as a
*Signing* key if you turned signing on).

## Fresh machine

The chicken-and-egg problem (you need git and a key to clone the repo that sets
up git and keys) doesn't apply:

1. `bootstrap.sh` clones over **public HTTPS**, or downloads a tarball when git
   isn't installed yet, and turns it into a real clone once install.sh has
   installed git.
2. `dutils init` runs `git-setup`, then offers to switch the dotfiles remote
   from HTTPS to SSH. Your username is in the personal profile's orgs, so
   that remote uses your personal key automatically.

## Migrating from the old setup

The previous design (gmail hardcoded in the tracked config, `config-local` for
the work email, `git@github-private:` remotes) is imported with:

```bash
dutils git-setup migrate
```

It creates `personal` and `work` profiles from those files and keeps
`github-private` as an alias, so existing remotes keep working. Afterwards,
`~/.config/git/config-local` and `config-personal` are no longer read and can be
deleted.

## Notes

- `includeIf hasconfig:remote.*.url` needs git ≥ 2.36.
- On macOS, keys are added to the agent with the passphrase kept in the Keychain
  (`UseKeychain yes`). On Windows, start the agent once:
  `Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent`.
- `dutils secrets` uses the personal profile's key as its age identity.
