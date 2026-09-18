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
CONFIG_LOCAL = HOME / ".config" / "git" / "config-local"
PRIVATE_ZSH = HOME / ".config" / "zsh" / "conf.d" / "99-private.zsh"
SECRETS_DIR = SCRIPT_DIR.parent.parent / "secrets"


def _sibling(script: str, *args: str) -> None:
    """Run another dutils Python subcommand interactively."""
    subprocess.run([sys.executable, str(SCRIPT_DIR / script), *args])


def step_identity(yes: bool) -> None:
    section("1. Git identity")
    info("The repo defaults to your personal (gmail) identity. A work machine "
         "can set a different DEFAULT here (kept in ~/.config/git/config-local, "
         "gitignored). Personal repos via the github-private remote stay gmail "
         "either way.")
    if CONFIG_LOCAL.exists():
        info(f"config-local already present ({CONFIG_LOCAL}). Leaving it as-is.")
        return
    if not confirm("Is this a WORK machine (set a work email as the default)?"):
        info("Keeping the personal default. Nothing written.")
        return
    name = input("  Work git author name [Akash Goyal]: ").strip() or "Akash Goyal"
    email = input("  Work git email: ").strip()
    if not email:
        warn("No email given — skipping.")
        return
    CONFIG_LOCAL.parent.mkdir(parents=True, exist_ok=True)
    CONFIG_LOCAL.write_text(
        "# Machine-local git identity (gitignored, per-machine).\n"
        "# Written by `dutils init`. Personal repos still override to gmail via\n"
        "# the github-private includeIf in the tracked config.\n"
        "[user]\n"
        f"\tname = {name}\n"
        f"\temail = {email}\n"
    )
    ok(f"Wrote {CONFIG_LOCAL}")


def step_ssh(yes: bool) -> None:
    section("2. SSH keys")
    if yes or confirm("Set up SSH keys now (personal / work)?"):
        _sibling("ssh_setup.py")
    else:
        info("Skipped. Run later: dutils ssh-setup")


def step_secrets(yes: bool) -> None:
    section("3. Secrets")
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
    section("4. Theme")
    if yes:
        _sibling("theme.py", "auto")
        return
    print("  1) auto (follow macOS)   2) dark   3) light   4) skip")
    choice = input("  Choose [1/2/3/4]: ").strip()
    mode = {"1": "auto", "2": "dark", "3": "light"}.get(choice)
    if mode:
        _sibling("theme.py", mode)
    else:
        info("Skipped. Run later: dutils theme")


def step_private(yes: bool) -> None:
    section("5. Machine-local shell overrides")
    if PRIVATE_ZSH.exists():
        info(f"{PRIVATE_ZSH.name} already present. Leaving it as-is.")
        return
    if not PRIVATE_ZSH.parent.exists():
        info("zsh conf.d not found (stow the zsh package first) — skipping.")
        return
    if yes or confirm("Create a starter 99-private.zsh (gitignored) for secrets/overrides?"):
        PRIVATE_ZSH.write_text(
            "#!/usr/bin/env zsh\n"
            "# Machine-local overrides — gitignored, sourced last.\n"
            "# Put secrets, per-machine PATH tweaks, and extra `hash -d` bookmarks here.\n"
            "#   export SOME_TOKEN=...\n"
            "#   hash -d work=~/work\n"
        )
        ok(f"Created {PRIVATE_ZSH}")


def step_health(yes: bool) -> None:
    section("6. Health check")
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
    step_ssh(args.yes)
    step_secrets(args.yes)
    step_theme(args.yes)
    step_private(args.yes)
    step_health(args.yes)

    print()
    ok("Setup complete. Open a new shell (`exec zsh`) to load everything.")


if __name__ == "__main__":
    main()
