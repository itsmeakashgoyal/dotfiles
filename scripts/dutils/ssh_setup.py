#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/ssh_setup.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Cross-platform SSH key setup for MULTIPLE GitHub identities (personal +
# company/professional), replacing the old bash-only setup_ssh.sh. Works on
# macOS, Linux, and Windows (run via `dutils ssh-setup`, which is Python on all
# three — Windows has no bash for the old .sh).
#
# For each profile it:
#   1. generates an ed25519 key (~/.ssh/<key-name>) if one isn't there yet,
#   2. writes an idempotent `Host <alias>` block into ~/.ssh/config,
#   3. adds the key to the agent (best effort) and copies the public key to the
#      clipboard so you can paste it into GitHub → Settings → SSH keys.
#
# The `Host <alias>` values are the hinge that makes the git identity split
# cross-platform: git/.config/git/config keys its `includeIf hasconfig:...`
# off `git@github-private:*`, so cloning/adding a remote through the personal
# alias makes that repo commit with the personal (gmail) identity on ANY
# machine — no per-machine git edits. See docs/SSH.md.

import argparse
import os
import platform
import stat
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
from dutil import ok, info, step, warn, fail, section, confirm  # noqa: E402

IS_WINDOWS = platform.system() == "Windows"
IS_MAC = platform.system() == "Darwin"
HOME = Path.home()
SSH_DIR = HOME / ".ssh"
SSH_CONFIG = SSH_DIR / "config"
# Machine-local git identity override (gitignored). Referenced by
# git/.config/git/config via `[include] path = ~/.config/git/config-local`.
GIT_CONFIG_LOCAL = HOME / ".config" / "git" / "config-local"

# Built-in profiles. `alias` is the ~/.ssh/config Host name you clone through;
# `key` is the private-key filename under ~/.ssh. Personal deliberately keeps
# the github-private / id_ed25519_private names the git config's includeIf and
# any existing remotes already rely on.
PROFILES: dict[str, dict[str, str]] = {
    "personal": {"alias": "github-private", "key": "id_ed25519_private", "host": "github.com"},
    "work":     {"alias": "github-work",    "key": "id_ed25519_work",    "host": "github.com"},
}

# Markers delimiting a block this tool owns, so re-running replaces its own
# block cleanly instead of appending duplicates or touching hand-written ones.
_BEGIN = "# >>> dutils ssh-setup: {alias} >>>"
_END = "# <<< dutils ssh-setup: {alias} <<<"


def _require_ssh_keygen() -> None:
    from shutil import which
    if which("ssh-keygen") is None:
        fail("ssh-keygen not found on PATH. Install OpenSSH (git ships it on "
             "Windows/macOS; `apt install openssh-client` on Linux) and retry.")
        sys.exit(1)


def _ensure_ssh_dir() -> None:
    SSH_DIR.mkdir(parents=True, exist_ok=True)
    if not IS_WINDOWS:
        os.chmod(SSH_DIR, stat.S_IRWXU)  # 0700


def generate_key(key_path: Path, email: str, key_type: str, assume_yes: bool) -> bool:
    """Create the key if absent. Returns True if a new key was generated."""
    if key_path.exists():
        info(f"Key already exists, reusing: {key_path}")
        return False

    step(f"Generating {key_type} key: {key_path}")
    subprocess.run(
        ["ssh-keygen", "-t", key_type, "-C", email, "-f", str(key_path), "-N", ""],
        check=True,
    )
    if not IS_WINDOWS:
        os.chmod(key_path, stat.S_IRUSR | stat.S_IWUSR)              # 0600
        os.chmod(key_path.with_suffix(".pub"), stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH)  # 0644
    else:
        info("On Windows, OpenSSH uses NTFS ACLs rather than POSIX bits — a key "
             "you created under your own profile is already private.")
    ok(f"Key generated: {key_path}")
    return True


def upsert_host_block(alias: str, host: str, key_path: Path) -> None:
    """Idempotently write a `Host <alias>` block into ~/.ssh/config."""
    begin, end = _BEGIN.format(alias=alias), _END.format(alias=alias)
    # ~ keeps the config portable across machines/users; ssh expands it itself.
    ident = "~/.ssh/" + key_path.name
    lines = [
        begin,
        f"Host {alias}",
        f"    HostName {host}",
        "    User git",
        f"    IdentityFile {ident}",
        "    IdentitiesOnly yes",
        "    AddKeysToAgent yes",
    ]
    if IS_MAC:
        lines.append("    UseKeychain yes")  # persist passphrase in the Keychain
    lines.append(end)
    block = "\n".join(lines) + "\n"

    existing = SSH_CONFIG.read_text() if SSH_CONFIG.exists() else ""
    if begin in existing and end in existing:
        pre, _, rest = existing.partition(begin)
        _, _, post = rest.partition(end)
        new = pre.rstrip("\n") + ("\n\n" if pre.strip() else "") + block + post.lstrip("\n")
        action = "Updated"
    else:
        new = (existing.rstrip("\n") + "\n\n" if existing.strip() else "") + block
        action = "Added"

    SSH_CONFIG.write_text(new)
    if not IS_WINDOWS:
        os.chmod(SSH_CONFIG, stat.S_IRUSR | stat.S_IWUSR)  # 0600
    ok(f"{action} Host '{alias}' → {host} (key {ident}) in {SSH_CONFIG}")


def add_to_agent(key_path: Path) -> None:
    # On macOS prefer the Keychain-persisting form, but fall back to plain
    # `ssh-add` — a non-Apple ssh-add on PATH (e.g. Homebrew OpenSSH) rejects
    # `--apple-use-keychain`. stderr is suppressed so its usage/no-agent noise
    # doesn't drown out our own guidance below.
    attempts = []
    if IS_MAC:
        attempts.append(["ssh-add", "--apple-use-keychain", str(key_path)])
    attempts.append(["ssh-add", str(key_path)])
    for cmd in attempts:
        try:
            if subprocess.run(cmd, stderr=subprocess.DEVNULL).returncode == 0:
                ok("Added to ssh-agent")
                return
        except FileNotFoundError:
            break
    warn("Could not add the key to the agent automatically. Start it and add "
         "the key manually:")
    if IS_WINDOWS:
        info("  Start-Service ssh-agent   (once, as admin: Set-Service ssh-agent -StartupType Automatic)")
    info(f"  ssh-add {key_path}")


def show_public_key(key_path: Path, copy: bool) -> None:
    pub = key_path.with_suffix(".pub")
    if not pub.exists():
        return
    text = pub.read_text().strip()
    section("Public key — add it at https://github.com/settings/keys")
    print(text)
    if copy and _copy_clipboard(text):
        ok("Public key copied to clipboard")


def _copy_clipboard(text: str) -> bool:
    from shutil import which
    if IS_MAC:
        cmds = [["pbcopy"]]
    elif IS_WINDOWS:
        cmds = [["clip"]]
    else:  # Linux: Wayland then X11
        cmds = [["wl-copy"], ["xclip", "-selection", "clipboard"], ["xsel", "-ib"]]
    for cmd in cmds:
        if which(cmd[0]):
            try:
                subprocess.run(cmd, input=text.encode(), check=True)
                return True
            except subprocess.CalledProcessError:
                continue
    return False


def maybe_write_work_git_identity(name: str, email: str, assume_yes: bool) -> None:
    """Offer to set the machine's DEFAULT git identity to the work one.

    Work repos are usually cloned with ordinary github.com/enterprise remotes,
    so a remote-alias includeIf can't catch them — the reliable knob is the
    machine default. config-local is gitignored, so it stays per-machine and
    never leaks the work email into the public repo. Personal repos still
    override back to gmail via the includeIf on the github-private alias.
    """
    prompt = (f"Set this machine's DEFAULT git identity to work "
              f"({name} <{email}>) via ~/.config/git/config-local?")
    if not (assume_yes or confirm(prompt)):
        info("Skipped. Work repos will use whatever the current git default is.")
        return
    GIT_CONFIG_LOCAL.parent.mkdir(parents=True, exist_ok=True)
    GIT_CONFIG_LOCAL.write_text(
        "# Machine-local git identity (gitignored, per-machine).\n"
        "# Written by `dutils ssh-setup`. Sets the DEFAULT identity on this\n"
        "# machine; personal repos still override to gmail via the\n"
        "# github-private includeIf in the tracked config.\n"
        "[user]\n"
        f"\tname = {name}\n"
        f"\temail = {email}\n"
    )
    ok(f"Wrote {GIT_CONFIG_LOCAL}")


def setup_profile(profile: str, args: argparse.Namespace) -> None:
    defaults = PROFILES[profile]
    alias = args.alias or defaults["alias"]
    host = args.host or defaults["host"]
    key_name = args.key_name or defaults["key"]
    key_path = SSH_DIR / key_name

    email = args.email or input(f"  Email for the {profile} key: ").strip()
    if not email:
        fail("An email is required.")
        sys.exit(1)

    section(f"SSH profile: {profile}")
    generate_key(key_path, email, args.key_type, args.yes)
    upsert_host_block(alias, host, key_path)
    add_to_agent(key_path)
    show_public_key(key_path, copy=not args.no_clipboard)

    section("Git identity")
    if profile == "personal":
        info("Personal repos (remotes via the 'github-private' alias) already "
             "commit as gmail through the includeIf in git/.config/git/config — "
             "nothing else to do.")
    else:
        name = args.name or input("  Git author name for work commits "
                                  "[Akash Goyal]: ").strip() or "Akash Goyal"
        maybe_write_work_git_identity(name, email, args.yes)

    section("Next steps")
    info(f"Add the public key above to the correct GitHub account, then clone via")
    info(f"  git clone git@{alias}:<owner>/<repo>.git")
    info(f"or point an existing repo at it:")
    info(f"  git remote set-url origin git@{alias}:<owner>/<repo>.git")


def _pick_profiles_interactively() -> list[str]:
    print("Which SSH profile(s) do you want to set up?")
    print("  1) personal   2) work   3) both")
    choice = input("Choose [1/2/3]: ").strip()
    return {"1": ["personal"], "2": ["work"], "3": ["personal", "work"]}.get(choice, [])


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="dutils ssh-setup",
        description="Set up SSH keys + ~/.ssh/config aliases for personal and "
                    "work GitHub identities (cross-platform).",
    )
    parser.add_argument("--profile", choices=list(PROFILES), help="Which profile to set up.")
    parser.add_argument("--all", action="store_true", help="Set up both personal and work.")
    parser.add_argument("-e", "--email", help="Email for the key comment / git identity.")
    parser.add_argument("--name", help="Git author name for the work identity.")
    parser.add_argument("--host", help="SSH HostName (default github.com; e.g. an enterprise host).")
    parser.add_argument("--alias", help="Override the ~/.ssh/config Host alias.")
    parser.add_argument("--key-name", help="Override the private-key filename under ~/.ssh.")
    parser.add_argument("--key-type", default="ed25519", choices=["ed25519", "rsa"],
                        help="Key type (default ed25519).")
    parser.add_argument("--no-clipboard", action="store_true", help="Don't copy the public key.")
    parser.add_argument("-y", "--yes", action="store_true", help="Assume yes for prompts.")
    args = parser.parse_args()

    _require_ssh_keygen()
    _ensure_ssh_dir()

    if args.all:
        profiles = ["personal", "work"]
    elif args.profile:
        profiles = [args.profile]
    else:
        profiles = _pick_profiles_interactively()
        if not profiles:
            fail("No profile selected.")
            sys.exit(1)
        # A single --email/--alias/--key-name can't sanely apply to two keys.
        if len(profiles) > 1 and (args.email or args.alias or args.key_name):
            fail("--email/--alias/--key-name can't be shared across both "
                 "profiles; run the command once per profile instead.")
            sys.exit(1)

    for profile in profiles:
        setup_profile(profile, args)

    print()
    ok("SSH setup complete.")


if __name__ == "__main__":
    main()
