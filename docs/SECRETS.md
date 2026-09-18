# Encrypted secrets (`dutils secrets`)

Keep secrets **in the repo, encrypted**, instead of scattering them in gitignored
files you have to copy to each machine by hand. Uses [`age`](https://age-encryption.org)
with your **SSH key** as the identity — no new key to manage — so the same secret
travels with your dotfiles and any machine holding your SSH private key can
decrypt it.

Everything else in this setup stays plain Stow.

## Model

Secrets live under `secrets/`, **encrypted** (`*.age`), mirroring `$HOME`:

```text
secrets/.ssh/config.age          ↔  ~/.ssh/config
secrets/.config/foo/token.age    ↔  ~/.config/foo/token
```

- Only `*.age` and `.recipients` are committed. `.recipients` holds **public**
  keys (safe to commit). A `.gitignore` in `secrets/` blocks anything that isn't
  encrypted, so a stray plaintext file can't be committed by accident.
- **Plaintext never lives in the repo** — it only exists at the real target
  under `$HOME` after you decrypt.
- Encryption recipient = your personal SSH **public** key; decryption identity =
  the matching **private** key (default `~/.ssh/id_ed25519_private`, from
  `dutils ssh-setup`). Override with `DOTFILES_AGE_IDENTITY`.

## Commands

```bash
dutils secrets init                 # seed secrets/.recipients from your SSH pubkey
dutils secrets add  ~/.ssh/config   # encrypt an existing $HOME file into the repo
dutils secrets edit ~/.config/x     # decrypt → $EDITOR → re-encrypt (create if new)
dutils secrets decrypt ~/.ssh/config  # restore one secret to $HOME
dutils secrets decrypt --all        # restore everything (new-machine setup)
dutils secrets list                 # what's managed + whether it's decrypted
```

`decrypt` asks before overwriting an existing target (use `-f`/`--force` to skip),
and writes secrets `0600`.

## Typical flows

**Add a secret**
```bash
dutils secrets init                 # once per repo
dutils secrets add ~/.ssh/config
git add secrets/ && git commit -m "secrets: add ssh config"
```

**New machine**
```bash
dutils ssh-setup --profile personal # ensure the SSH key exists first
dutils secrets decrypt --all        # restore every secret to $HOME
```

**Add another machine as a decryptor** — append that machine's SSH *public* key
to `secrets/.recipients`, then re-encrypt each secret (`dutils secrets edit …`,
save with no change, or `add` again) so it's encrypted to the new recipient too,
and commit.

## Notes

- If your SSH key has a passphrase, `age` prompts for it on decrypt (add it to
  the agent to avoid re-typing).
- `age` is installed by the package step (Brewfile / `nix/home.nix` / Scoop).
- Rotating: change the recipient(s) in `.recipients` and re-encrypt; the old
  `.age` blobs in git history were only ever readable by the old key.
