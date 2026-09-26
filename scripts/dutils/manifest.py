#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/manifest.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# `dutils manifest` — render packages.toml into the files that actually run.
#
# Every package manager this repo touches used to keep its own hand-maintained
# list (brew/Brewfile, nix/home.nix, windows.ps1's $SCOOP_PACKAGES and
# $SYMLINK_MAP, linux.sh's apt array). They drifted, silently. Now packages.toml
# is the source of truth and those lists are generated regions, delimited by:
#
#   # BEGIN GENERATED: <id> ...
#   # END GENERATED: <id>
#
# Only the text between the markers is rewritten — everything else in those
# files stays hand-written.
#
# Usage:
#   dutils manifest generate     # rewrite every generated region
#   dutils manifest check        # fail if a region is stale (CI gate)
#   dutils manifest list         # show what's installed where
#   dutils manifest stow-packages  # space-separated Stow list (used by Makefile)

from __future__ import annotations

import argparse
import difflib
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
import manifest as mf  # noqa: E402

REPO = mf.REPO_ROOT

BEGIN = "BEGIN GENERATED: {id}"
END   = "END GENERATED: {id}"


# ==============================================================================
# Region splicing
# ==============================================================================


def splice(text: str, region: str, body: list[str]) -> str:
    """Replace the body between the BEGIN/END markers for `region`.

    The markers' own indentation is reused for the generated lines, so a region
    nested inside a PowerShell hashtable or a Nix list stays correctly indented.
    """
    # `(?![\w-])` stops a region id matching a longer one that starts with it —
    # without it, "apt" would also match the "apt-optional" marker and rewrite
    # the wrong block (or, if an END marker were missing, swallow everything
    # between the two regions).
    begin_re = re.compile(
        rf"^([ \t]*)(\S*\s*){re.escape(BEGIN.format(id=region))}(?![\w-]).*$", re.M
    )
    end_re = re.compile(
        rf"^[ \t]*\S*\s*{re.escape(END.format(id=region))}(?![\w-]).*$", re.M
    )

    begin = begin_re.search(text)
    if not begin:
        raise SystemExit(f"error: no '{BEGIN.format(id=region)}' marker found")
    end = end_re.search(text, begin.end())
    if not end:
        raise SystemExit(f"error: no '{END.format(id=region)}' marker found")

    indent = begin.group(1)
    rendered = "\n".join(indent + line if line else "" for line in body)
    return text[: begin.end()] + "\n" + rendered + "\n" + text[end.start() :]


def _pad(entry: str, width: int, comment: str) -> str:
    if not comment:
        return entry
    return f"{entry.ljust(width)} # {comment}"


def _by_category(packages: list[mf.Package]) -> list[tuple[str, list[mf.Package]]]:
    groups: dict[str, list[mf.Package]] = {}
    for pkg in packages:
        groups.setdefault(pkg.category, []).append(pkg)
    return list(groups.items())


# ==============================================================================
# Renderers — one per generated region
# ==============================================================================


def render_brew(m: mf.Manifest) -> list[str]:
    def entries(selector) -> list[mf.Package]:
        return [p for p in m.packages if p.brew and selector(p)]

    def block(packages: list[mf.Package], indent: str = "") -> list[str]:
        if not packages:
            return []
        width = max(len(f'{"cask" if p.cask else "brew"} "{p.brew}"') for p in packages)
        lines: list[str] = []
        for category, group in _by_category(packages):
            lines.append("")
            lines.append(f"{indent}# {category}")
            for pkg in group:
                keyword = "cask" if pkg.cask else "brew"
                lines.append(indent + _pad(f'{keyword} "{pkg.brew}"', width, pkg.desc))
        return lines[1:]  # drop the leading blank

    out = block(entries(lambda p: p.brew_os == ""))

    mac = entries(lambda p: p.brew_os == "mac")
    if mac:
        out += ["", "if OS.mac?"] + block(mac, indent="    ") + ["end"]

    linux = entries(lambda p: p.brew_os == "linux")
    if linux:
        out += ["", "if OS.linux?"] + block(linux, indent="    ") + ["end"]

    return out


def render_nix(m: mf.Manifest) -> list[str]:
    packages = [p for p in m.packages if p.nix]
    if not packages:
        return []
    lines: list[str] = []
    for category, group in _by_category(packages):
        lines.append("")
        lines.append(f"# {category}")
        for pkg in group:
            # Note the Homebrew name when the nixpkgs attribute differs, so the
            # naming mismatches are visible in the file itself.
            desc = pkg.desc
            if pkg.brew and pkg.nix != pkg.brew and desc:
                desc = f"{desc} (Homebrew: {pkg.brew})"
            # nixfmt normalises trailing comments to a single leading space, so
            # no column padding here — `nixfmt --check` is a CI gate.
            lines.append(f"{pkg.nix} # {desc}" if desc else pkg.nix)
    return lines[1:]


def render_scoop(m: mf.Manifest) -> list[str]:
    packages = [p for p in m.packages if p.scoop]
    if not packages:
        return []
    width = max(len(f'"{p.scoop}"') for p in packages)
    lines: list[str] = []
    for category, group in _by_category(packages):
        lines.append("")
        lines.append(f"# {category}")
        for pkg in group:
            lines.append(_pad(f'"{pkg.scoop}"', width, pkg.desc))
    return lines[1:]


def render_symlinks(m: mf.Manifest) -> list[str]:
    entries = m.stow_for("windows")
    if not entries:
        return []
    keys = [f'"{e.repo_path.replace("/", chr(92))}"' for e in entries]
    width = max(len(k) for k in keys)
    return [f'{key.ljust(width)} = "{entry.win_target}"' for key, entry in zip(keys, entries)]


def render_apt(m: mf.Manifest) -> list[str]:
    packages = [p for p in m.system if not p.optional]
    if not packages:
        return []
    width = max(len(p.name) for p in packages)
    return [_pad(p.name, width, p.desc) for p in packages]


def render_apt_optional(m: mf.Manifest) -> list[str]:
    packages = [p for p in m.system if p.optional]
    if not packages:
        return []
    width = max(len(p.name) for p in packages)
    return [_pad(p.name, width, p.desc) for p in packages]


def render_stow(m: mf.Manifest) -> list[str]:
    return ["STOW_PACKAGES := " + " ".join(m.stow_packages())]


# Region id -> (file, renderer)
REGIONS: dict[str, tuple[Path, object]] = {
    "brew":         (REPO / "brew" / "Brewfile",                   render_brew),
    "nix":          (REPO / "nix" / "home.nix",                    render_nix),
    "scoop":        (REPO / "windows" / "windows.ps1",             render_scoop),
    "symlinks":     (REPO / "windows" / "windows.ps1",             render_symlinks),
    "apt":          (REPO / "scripts" / "setup" / "linux.sh",      render_apt),
    "apt-optional": (REPO / "scripts" / "setup" / "linux.sh",      render_apt_optional),
    "stow":         (REPO / "Makefile",                            render_stow),
}


def render_all(m: mf.Manifest) -> dict[Path, str]:
    """Apply every region to its file, returning path -> new content."""
    pending: dict[Path, str] = {}
    for region, (path, renderer) in REGIONS.items():
        text = pending.get(path) or path.read_text(encoding="utf-8")
        pending[path] = splice(text, region, renderer(m))
    return pending


# ==============================================================================
# Commands
# ==============================================================================


def cmd_generate(m: mf.Manifest, _args: argparse.Namespace) -> int:
    changed = []
    for path, new in render_all(m).items():
        if path.read_text(encoding="utf-8") != new:
            path.write_text(new, encoding="utf-8")
            changed.append(path)

    if not changed:
        print("✓ All generated regions already up to date")
        return 0
    for path in changed:
        print(f"✓ Updated {path.relative_to(REPO)}")
    return 0


def cmd_check(m: mf.Manifest, _args: argparse.Namespace) -> int:
    # The fallback TOML parser only runs on Python < 3.11 (macOS ships 3.9), so
    # verify it here — where tomllib exists — rather than discovering a
    # divergence on the machine that can't detect it.
    if sys.version_info >= (3, 11) and not mf.selftest():
        print(
            "✗ The fallback TOML parser in scripts/lib/manifest.py no longer "
            "agrees with tomllib on packages.toml",
            file=sys.stderr,
        )
        return 1

    stale = []
    for path, new in render_all(m).items():
        old = path.read_text(encoding="utf-8")
        if old == new:
            continue
        stale.append(path)
        rel = str(path.relative_to(REPO))
        sys.stdout.writelines(
            difflib.unified_diff(
                old.splitlines(keepends=True),
                new.splitlines(keepends=True),
                fromfile=f"{rel} (committed)",
                tofile=f"{rel} (from packages.toml)",
            )
        )

    if stale:
        print(
            f"\n✗ {len(stale)} file(s) drifted from packages.toml. "
            "Run: dutils manifest generate",
            file=sys.stderr,
        )
        return 1

    print("✓ Every generated region matches packages.toml")
    return 0


def cmd_list(m: mf.Manifest, args: argparse.Namespace) -> int:
    platforms = [args.platform] if args.platform else list(mf.PLATFORMS)
    for platform in platforms:
        packages = m.for_platform(platform)
        print(f"\n{platform} ({len(packages)} packages)")
        print("─" * 60)
        for pkg in packages:
            manager = {"macos": pkg.brew, "linux": pkg.nix or pkg.brew, "windows": pkg.scoop}[
                platform
            ]
            flags = []
            if pkg.critical:
                flags.append("critical")
            if pkg.check != "full":
                flags.append(f"check={pkg.check}")
            suffix = f"  [{', '.join(flags)}]" if flags else ""
            print(f"  {pkg.name:<28} {manager}{suffix}")

    missing = [
        p.name
        for p in m.packages
        if not any(p.available_on(plat) for plat in mf.PLATFORMS)
    ]
    if missing:
        print(f"\n⚠ Installed nowhere: {', '.join(missing)}")
    return 0


def cmd_stow_packages(m: mf.Manifest, _args: argparse.Namespace) -> int:
    print(" ".join(m.stow_packages()))
    return 0


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="dutils manifest",
        description="Render packages.toml into the per-manager package lists",
    )
    sub = parser.add_subparsers(dest="command")

    sub.add_parser("generate", help="rewrite every generated region")
    sub.add_parser("check", help="fail if a generated region is stale")
    list_parser = sub.add_parser("list", help="show what gets installed where")
    list_parser.add_argument("--platform", choices=mf.PLATFORMS)
    sub.add_parser("stow-packages", help="space-separated Stow package list")

    args = parser.parse_args()
    handlers = {
        "generate":      cmd_generate,
        "check":         cmd_check,
        "list":          cmd_list,
        "stow-packages": cmd_stow_packages,
    }
    if args.command not in handlers:
        parser.print_help()
        sys.exit(1)

    sys.exit(handlers[args.command](mf.load(), args))


if __name__ == "__main__":
    main()
