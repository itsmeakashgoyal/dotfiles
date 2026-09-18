# secrets/

Encrypted secrets, managed by `dutils secrets` (age + your SSH key). See
[docs/SECRETS.md](../docs/SECRETS.md) for the full guide.

- Files here are **encrypted** (`*.age`) and mirror `$HOME`, e.g.
  `secrets/.ssh/config.age` ↔ `~/.ssh/config`.
- `.recipients` holds **public** keys only (safe to commit) — the SSH public
  keys allowed to decrypt.
- Plaintext never lives here: it only exists at the real target under `$HOME`.
  The `.gitignore` in this directory blocks anything that isn't `*.age`.

Quick start:

```bash
dutils secrets init                 # seed .recipients from your SSH public key
dutils secrets add  ~/.ssh/config   # encrypt a file into the repo
dutils secrets decrypt --all        # restore secrets to $HOME on a new machine
```
