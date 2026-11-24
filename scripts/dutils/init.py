#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/init.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# First-run setup wizard — the "new machine" flow. Ties the other dutils pieces
# together (git identity, SSH keys, theme, secrets, private overrides) with a
# short series of optional, idempotent prompts, so a fresh machine goes from
# `make install` to fully personalized with one command. Safe to re-run.
#
# Usage: dutils init [-y]

import argparse
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR.parent / "lib"))
from dutil import ok, info, step, warn, section, confirm  # noqa: E402

HOME = Path.home()
GIT_PROFILES = HOME / ".config" / "dotfiles" / "git" / "profiles.json"
PRIVATE_ZSH = HOME / ".config" / "zsh" / "conf.d" / "99-private.zsh"
SECRETS_DIR = SCRIPT_DIR.parent.parent / "secrets"


def _sibling(script: str, *args: str) -> None:
    """Run another dutils Python subcommand interactively."""
    subprocess.run([sys.executable, str(SCRIPT_DIR / script), *args])


def step_identity(yes: bool) -> None:
    section("1. Git identities + SSH keys")
    info("Personal plus any number of work profiles. Each repo picks the right "
         "email and SSH key automatically (by folder, GitHub org or enterprise "
         "host). Stored in ~/.config/dotfiles/git/, outside the repo.")
    if GIT_PROFILES.exists():
        info("Profiles already set up — showing them (edit: dutils git-setup).")
        _sibling("git_setup.py", "status")
        return
    if yes or confirm("Set up git identities now?"):
        _sibling("git_setup.py")
    else:
        warn("Skipped — git will refuse to commit until you run: dutils git-setup")


def step_secrets(yes: bool) -> None:
    section("2. Secrets")
    ages = list(SECRETS_DIR.rglob("*.age")) if SECRETS_DIR.exists() else []
    if not ages:
        info("No encrypted secrets in the repo yet — nothing to restore.")
        return
    info(f"{len(ages)} encrypted secret(s) found.")
    if yes or confirm("Decrypt them to $HOME now?"):
        _sibling("secrets.py", "decrypt", "--all")
    else:
        info("Skipped. Run later: dutils secrets decrypt --all")


def step_theme(yes: bool) -> None:
    section("3. Theme (Gruvbox)")
    info("Gruvbox Dark everywhere by default; this picks the TERMINAL mode.")
    if yes:
        _sibling("theme.py", "apply")
        return
    print("  1) dark (default)   2) light   3) auto (follow the OS)   4) skip")
    choice = input("  Choose [1/2/3/4]: ").strip() or "1"
    mode = {"1": "dark", "2": "light", "3": "auto"}.get(choice)
    if mode:
        _sibling("theme.py", mode)
    else:
        info("Skipped. Run later: dutils theme")


def step_private(yes: bool) -> None:
    section("4. Machine-local shell overrides (work exports, tokens)")
    if PRIVATE_ZSH.exists():
        PRIVATE_ZSH.chmod(0o600)
        info(f"{PRIVATE_ZSH.name} already present (permissions set to owner-only).")
        return
    if not PRIVATE_ZSH.parent.exists():
        info("zsh conf.d not found (stow the zsh package first) — skipping.")
        return
    if yes or confirm("Create a starter 99-private.zsh (gitignored) for work exports/secrets?"):
        PRIVATE_ZSH.write_text(
            "#!/usr/bin/env zsh\n"
            "# Machine-local overrides: gitignored, owner-only (chmod 600), sourced last.\n"
            "# Work exports, tokens, per-machine PATH tweaks and `hash -d` bookmarks.\n"
            "#   export ARTIFACTORY_USER=...\n"
            "#   export SOME_TOKEN=...\n"
            "#   hash -d work=~/work\n"
        )
        PRIVATE_ZSH.chmod(0o600)
        ok(f"Created {PRIVATE_ZSH} (owner-only)")


def step_health(yes: bool) -> None:
    section("5. Health check")
    check = SCRIPT_DIR.parent / "verify" / "check.py"
    if not check.exists():
        return
    if yes or confirm("Run a quick health check now?"):
        subprocess.run([sys.executable, str(check), "--quick"])


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="dutils init",
        description="First-run setup wizard for a new machine (idempotent).")
    parser.add_argument("-y", "--yes", action="store_true",
                        help="Accept the default action at each step (still prompts "
                             "for values like emails).")
    args = parser.parse_args()

    section("dutils init — new-machine setup")
    info("Each step is optional and safe to re-run. Ctrl-C to stop anytime.")

    step_identity(args.yes)
    step_secrets(args.yes)
    step_theme(args.yes)
    step_private(args.yes)
    step_health(args.yes)

    print()
    ok("Setup complete. Open a new shell (`exec zsh`) to load everything.")


if __name__ == "__main__":
    main()
