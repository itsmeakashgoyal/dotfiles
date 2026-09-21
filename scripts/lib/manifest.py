#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/lib/manifest.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Loader for packages.toml — the single source of truth for every tool this
# repo installs and every Stow package it links.
#
# Sourced by two very different callers:
#   * scripts/dutils/manifest.py  — renders the generated regions
#   * scripts/verify/check.py     — drives the health/verification checks
#
# Because check.py runs on freshly-provisioned machines, this module must work
# on whatever Python is already there. `tomllib` only landed in 3.11 and macOS
# still ships 3.9 as /usr/bin/python3, so there's a small fallback parser that
# understands exactly the subset of TOML packages.toml uses.

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

REPO_ROOT     = Path(__file__).resolve().parent.parent.parent
MANIFEST_PATH = REPO_ROOT / "packages.toml"

PLATFORMS = ("macos", "linux", "windows")

# Which package manager serves which platform.
MANAGER_PLATFORM = {"brew": "macos", "nix": "linux", "scoop": "windows"}


# ==============================================================================
# Minimal TOML reader (fallback for Python < 3.11)
# ==============================================================================


def _parse_scalar(raw: str) -> Any:
    raw = raw.strip()
    if raw.startswith("[") and raw.endswith("]"):
        inner = raw[1:-1].strip()
        if not inner:
            return []
        return [
            _parse_scalar(part)
            for part in re.findall(r"\"[^\"]*\"|'[^']*'|[^,\s]+", inner)
        ]
    # Literal strings (single quotes) must come first in spirit: they take the
    # contents verbatim, which is why packages.toml uses them for Windows paths
    # like '$env:LOCALAPPDATA\nvim' — in a basic (double-quoted) string TOML
    # would turn that \n into a newline.
    if len(raw) >= 2 and raw[0] == raw[-1] and raw[0] in ("'", '"'):
        return raw[1:-1]
    if raw == "true":
        return True
    if raw == "false":
        return False
    try:
        return int(raw)
    except ValueError:
        return raw


def _strip_comment(line: str) -> str:
    """Drop a trailing # comment, honouring both quoted-string forms."""
    out: list[str] = []
    quote = ""
    for ch in line:
        if quote:
            if ch == quote:
                quote = ""
        elif ch in ("'", '"'):
            quote = ch
        elif ch == "#":
            break
        out.append(ch)
    return "".join(out)


def _simple_toml_loads(text: str) -> dict[str, Any]:
    """Parse the TOML subset packages.toml uses: tables, arrays of tables,
    strings, booleans, integers and flat string arrays."""
    doc: dict[str, Any] = {}
    current: dict[str, Any] | None = None

    for raw_line in text.splitlines():
        line = _strip_comment(raw_line).strip()
        if not line:
            continue

        if line.startswith("[["):
            name = line[2:].split("]]")[0].strip()
            current = {}
            doc.setdefault(name, []).append(current)
            continue

        if line.startswith("["):
            name = line[1:].split("]")[0].strip()
            current = doc.setdefault(name, {})
            continue

        if "=" in line and current is not None:
            key, _, value = line.partition("=")
            current[key.strip()] = _parse_scalar(value)

    return doc


def _load_toml(path: Path) -> dict[str, Any]:
    try:
        import tomllib

        with path.open("rb") as fh:
            return tomllib.load(fh)
    except ImportError:
        return _simple_toml_loads(path.read_text(encoding="utf-8"))


def selftest(path: Path | None = None) -> bool:
    """Assert the fallback parser agrees with tomllib on the real manifest.

    Only tomllib-capable interpreters can run this, which is exactly where it's
    useful: CI catches a fallback-parser regression before a Python 3.9 machine
    (macOS's /usr/bin/python3) silently loads the manifest wrong.
    """
    import tomllib

    target = path or MANIFEST_PATH
    text = target.read_text(encoding="utf-8")
    return tomllib.loads(text) == _simple_toml_loads(text)


# ==============================================================================
# Model
# ==============================================================================


@dataclass
class Package:
    name:         str
    desc:         str  = ""
    category:     str  = "Misc"
    brew:         str  = ""
    brew_os:      str  = ""       # "", "mac" or "linux"
    cask:         bool = False
    nix:          str  = ""
    scoop:        str  = ""
    apt:          str  = ""
    verify:       str  = ""
    critical:     bool = False
    check:        str  = "full"   # "quick" | "full" | "none"
    version_flag: str  = "--version"

    @property
    def binary(self) -> str:
        """Executable that proves this package is installed ('' = none)."""
        return self.verify if "verify" in self._explicit else self.name

    _explicit: set = field(default_factory=set, repr=False, compare=False)

    def available_on(self, platform: str) -> bool:
        if platform == "macos":
            return bool(self.brew) and self.brew_os in ("", "mac")
        if platform == "linux":
            return bool(self.nix) or (bool(self.brew) and self.brew_os == "linux")
        if platform == "windows":
            return bool(self.scoop)
        return False


@dataclass
class StowEntry:
    package:        str
    target:         str
    desc:           str  = ""
    source:         str  = ""
    windows_target: str  = ""
    critical:       bool = False
    platforms:      list[str] = field(default_factory=lambda: list(PLATFORMS))

    @property
    def repo_path(self) -> str:
        return self.source or f"{self.package}/{self.target}"

    @property
    def win_target(self) -> str:
        """Absolute Windows target, as a PowerShell-expandable string."""
        if self.windows_target:
            return self.windows_target
        return "$env:USERPROFILE\\" + self.target.replace("/", "\\")


@dataclass
class SystemPackage:
    name:     str
    desc:     str  = ""
    optional: bool = False


@dataclass
class Manifest:
    packages: list[Package]
    system: list[SystemPackage]
    stow: list[StowEntry]

    def for_platform(self, platform: str) -> list[Package]:
        return [p for p in self.packages if p.available_on(platform)]

    def stow_for(self, platform: str) -> list[StowEntry]:
        return [s for s in self.stow if platform in s.platforms]

    def stow_packages(self, platforms: tuple[str, ...] = ("macos", "linux")) -> list[str]:
        """Unique Stow package names, in manifest order, for the given platforms."""
        seen: list[str] = []
        for entry in self.stow:
            if any(p in entry.platforms for p in platforms) and entry.package not in seen:
                seen.append(entry.package)
        return seen

    def checks(self, tier: str, platform: str) -> list[Package]:
        """Packages whose binary should be verified at the given tier.

        `quick` is a subset of `full`, so a full run also covers quick entries.
        """
        tiers = {"quick"} if tier == "quick" else {"quick", "full"}
        return [
            p
            for p in self.packages
            if p.check in tiers and p.binary and p.available_on(platform)
        ]


def _field_names(cls: type) -> set[str]:
    return {f.name for f in cls.__dataclass_fields__.values() if not f.name.startswith("_")}


def load(path: Path | None = None) -> Manifest:
    data = _load_toml(path or MANIFEST_PATH)

    packages = []
    for raw in data.get("package", []):
        known = {k: v for k, v in raw.items() if k in _field_names(Package)}
        pkg = Package(**known)
        pkg._explicit = set(raw)
        packages.append(pkg)

    system = [
        SystemPackage(**{k: v for k, v in raw.items() if k in _field_names(SystemPackage)})
        for raw in data.get("system", [])
    ]
    stow = [
        StowEntry(**{k: v for k, v in raw.items() if k in _field_names(StowEntry)})
        for raw in data.get("stow", [])
    ]

    return Manifest(packages=packages, system=system, stow=stow)
