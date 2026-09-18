#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/zcompile.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Precompile the zsh config to bytecode (.zwc) so zsh doesn't re-parse the text
# of .zshrc + every conf.d/*.zsh on each startup. zsh automatically prefers
# `<file>.zwc` when it's newer than `<file>`, and falls back to the plain source
# when it's older — so a stale .zwc is never a correctness risk, just a missed
# speedup. Re-run after editing zsh config (sync does this automatically).
#
# Usage: dutils zcompile

import os
import subprocess
import sys
from pathlib import Path
from shutil import which

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
from dutil import ok, info, warn, fail, section  # noqa: E402


def main() -> None:
    if which("zsh") is None:
        fail("zsh not found — nothing to compile.")
        sys.exit(1)

    zdotdir = Path(os.environ.get("ZDOTDIR") or (Path.home() / ".config" / "zsh"))
    if not zdotdir.is_dir():
        fail(f"ZDOTDIR not found: {zdotdir}")
        sys.exit(1)

    section(f"Compiling zsh config in {zdotdir}")
    targets: list[Path] = []
    for p in (zdotdir / ".zshrc", zdotdir / ".p10k.zsh"):
        if p.is_file():
            targets.append(p)
    targets += sorted((zdotdir / "conf.d").glob("*.zsh"))

    if not targets:
        warn("No zsh files found to compile.")
        return

    # `zcompile -R` compiles for reading (source/eval). Batch them into one zsh
    # invocation. A failure on one file shouldn't abort the rest.
    compiled = 0
    for f in targets:
        r = subprocess.run(
            ["zsh", "-fc", 'zcompile -R -- "$1"', "zsh", str(f)],
            capture_output=True, text=True,
        )
        if r.returncode == 0:
            compiled += 1
        else:
            warn(f"skip {f.name}: {r.stderr.strip() or 'zcompile failed'}")

    ok(f"Compiled {compiled}/{len(targets)} files to .zwc")
    info("Open a new shell to use the compiled config. Edits auto-fall-back to "
         "source until you recompile.")


if __name__ == "__main__":
    main()
