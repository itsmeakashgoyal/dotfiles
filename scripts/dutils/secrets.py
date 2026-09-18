#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/secrets.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Encrypted secrets in the repo, via `age` with your SSH key. Secrets live
# ENCRYPTED under secrets/ mirroring $HOME:
#
#     secrets/.ssh/config.age        ↔  ~/.ssh/config
#     secrets/.config/foo/token.age  ↔  ~/.config/foo/token
#
# Only the .age files (and .recipients, which holds PUBLIC keys) are committed —
# plaintext only ever exists at the real target under $HOME, never in the repo.
# Encryption uses your personal SSH public key as the age recipient; decryption
# uses the matching private key. No new key to manage.
#
#     dutils secrets init                 # seed recipients from your SSH pubkey
#     dutils secrets add  ~/.ssh/config   # encrypt a file into the repo
#     dutils secrets edit ~/.ssh/config   # decrypt → $EDITOR → re-encrypt
#     dutils secrets decrypt --all        # restore every secret to $HOME
#     dutils secrets list                 # what's managed + whether present

import argparse
import os
import stat
import subprocess
import sys
import tempfile
from pathlib import Path
from shutil import which

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
from dutil import ok, info, step, warn, fail, section, confirm  # noqa: E402

HOME = Path.home()
DOTFILES_DIR = Path(__file__).resolve().parents[2]
SECRETS_DIR = DOTFILES_DIR / "secrets"
RECIPIENTS = SECRETS_DIR / ".recipients"

# Decryption identity: personal SSH key by default (matches `dutils ssh-setup`),
# overridable for machines that name it differently.
IDENTITY = Path(os.environ.get("DOTFILES_AGE_IDENTITY", HOME / ".ssh" / "id_ed25519_private"))
DEFAULT_PUBKEY = Path(str(IDENTITY) + ".pub")


def _require_age() -> None:
    if which("age") is None:
        fail("`age` is not installed. Install it: brew install age (macOS) / it's "
             "in nix/home.nix on Linux / scoop install age (Windows).")
        sys.exit(1)


def _rel_to_home(path: str) -> Path:
    """Normalize a user-given path to one relative to $HOME."""
    p = Path(path).expanduser()
    if not p.is_absolute():
        p = (HOME / p)
    try:
        return p.resolve().relative_to(HOME.resolve())
    except ValueError:
        fail(f"{p} is not under $HOME — this tool mirrors home-relative paths only.")
        sys.exit(1)


def _age_path(rel: Path) -> Path:
    return SECRETS_DIR / (str(rel) + ".age")


def _target_path(rel: Path) -> Path:
    return HOME / rel


def cmd_init(_args) -> None:
    section("Initialize age recipients")
    SECRETS_DIR.mkdir(parents=True, exist_ok=True)
    if not DEFAULT_PUBKEY.exists():
        fail(f"SSH public key not found: {DEFAULT_PUBKEY}\n"
             f"Run `dutils ssh-setup --profile personal` first, or set "
             f"DOTFILES_AGE_IDENTITY to your key path.")
        sys.exit(1)
    pub = DEFAULT_PUBKEY.read_text().strip()
    existing = RECIPIENTS.read_text() if RECIPIENTS.exists() else ""
    if pub.split()[1] in existing:  # compare the key body, ignore comment
        info("Your SSH public key is already a recipient.")
    else:
        with RECIPIENTS.open("a") as f:
            if existing and not existing.endswith("\n"):
                f.write("\n")
            f.write(pub + "\n")
        ok(f"Added your SSH public key to {RECIPIENTS}")
    info("Recipients (public keys) are safe to commit. Add another machine's "
         "key to this file so it can decrypt too.")


def _encrypt(src: Path, dest_age: Path) -> None:
    if not RECIPIENTS.exists():
        fail("No recipients yet. Run `dutils secrets init` first.")
        sys.exit(1)
    dest_age.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(["age", "-R", str(RECIPIENTS), "-o", str(dest_age), str(src)], check=True)


def _decrypt(src_age: Path, dest: Path) -> None:
    if not IDENTITY.exists():
        fail(f"Decryption identity not found: {IDENTITY} "
             f"(set DOTFILES_AGE_IDENTITY to override).")
        sys.exit(1)
    dest.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(["age", "-d", "-i", str(IDENTITY), "-o", str(dest), str(src_age)], check=True)
    if os.name != "nt":
        os.chmod(dest, stat.S_IRUSR | stat.S_IWUSR)  # 0600 — it's a secret


def cmd_add(args) -> None:
    _require_age()
    rel = _rel_to_home(args.path)
    src = _target_path(rel)
    if not src.exists():
        fail(f"No such file: {src}")
        sys.exit(1)
    dest = _age_path(rel)
    _encrypt(src, dest)
    ok(f"Encrypted {src}  →  {dest.relative_to(DOTFILES_DIR)}")
    info("Commit the .age file. The plaintext stays only at the target under $HOME.")


def cmd_decrypt(args) -> None:
    _require_age()
    if args.all:
        ages = sorted(SECRETS_DIR.rglob("*.age"))
        if not ages:
            info("No secrets to decrypt.")
            return
        targets = [(a, HOME / a.relative_to(SECRETS_DIR).with_suffix("")) for a in ages]
    else:
        rel = _rel_to_home(args.path)
        src = _age_path(rel)
        if not src.exists():
            fail(f"Not a managed secret: {src.relative_to(DOTFILES_DIR)}")
            sys.exit(1)
        targets = [(src, _target_path(rel))]

    for src_age, dest in targets:
        if dest.exists() and not args.force:
            if not confirm(f"Overwrite existing {dest}?"):
                info(f"Skipped {dest}")
                continue
        _decrypt(src_age, dest)
        ok(f"Decrypted → {dest}")


def cmd_edit(args) -> None:
    _require_age()
    rel = _rel_to_home(args.path)
    src_age = _age_path(rel)
    editor = os.environ.get("EDITOR", "nvim")
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td) / rel.name
        if src_age.exists():
            _decrypt(src_age, tmp)
        else:
            tmp.write_text("")
            info(f"New secret: {rel}")
        before = tmp.read_bytes()
        subprocess.run([*editor.split(), str(tmp)], check=True)
        if tmp.read_bytes() == before and src_age.exists():
            info("No changes.")
            return
        _encrypt(tmp, src_age)
    ok(f"Saved (encrypted) → {src_age.relative_to(DOTFILES_DIR)}")


def cmd_list(_args) -> None:
    section("Managed secrets")
    ages = sorted(SECRETS_DIR.rglob("*.age")) if SECRETS_DIR.exists() else []
    if not ages:
        info("None yet. Add one: dutils secrets add ~/.ssh/config")
        return
    for a in ages:
        rel = a.relative_to(SECRETS_DIR).with_suffix("")
        target = HOME / rel
        mark = "present" if target.exists() else "not decrypted"
        print(f"  {rel}  →  ~/{rel}  ({mark})")


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="dutils secrets",
        description="Encrypted secrets in the repo via age + your SSH key.")
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("init", help="Seed secrets/.recipients from your SSH public key")

    p_add = sub.add_parser("add", help="Encrypt a $HOME file into the repo")
    p_add.add_argument("path", help="Path under $HOME, e.g. ~/.ssh/config")

    p_dec = sub.add_parser("decrypt", help="Decrypt secret(s) back to $HOME")
    p_dec.add_argument("path", nargs="?", help="A single managed path (omit with --all)")
    p_dec.add_argument("--all", action="store_true", help="Decrypt every managed secret")
    p_dec.add_argument("-f", "--force", action="store_true", help="Overwrite without asking")

    p_edit = sub.add_parser("edit", help="Decrypt → $EDITOR → re-encrypt")
    p_edit.add_argument("path", help="Path under $HOME (created if new)")

    sub.add_parser("list", help="List managed secrets and whether they're present")

    args = parser.parse_args()
    if args.cmd == "decrypt" and not args.all and not args.path:
        parser.error("give a path or --all")

    {"init": cmd_init, "add": cmd_add, "decrypt": cmd_decrypt,
     "edit": cmd_edit, "list": cmd_list}[args.cmd](args)


if __name__ == "__main__":
    main()
