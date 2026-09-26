#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/verify/check.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Dotfiles verification — Python OOP implementation.
# Called by check.sh (which is a thin shim).
#
# Usage:
#   check.py              # quick health check (default)
#   check.py --quick      # quick health check
#   check.py --full       # full installation verification
#   check.py --packages   # compare installed packages vs packages.toml
#   check.py --system     # display system information
#   check.py --all        # run everything
#   check.py --help       # show this help

import sys

if sys.version_info < (3, 7):
    sys.exit("check.py requires Python 3.7+")

import os
import platform
import re
import shutil
import subprocess
import tempfile
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Literal

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
import manifest as mf  # noqa: E402
import osdetect  # noqa: E402


def repo_root() -> Path:
    """Locate the dotfiles checkout.

    check.py lives at <repo>/scripts/verify/, so the repo is always three levels
    up — that works for any clone location, including git worktrees. $DOTFILES_DIR
    still wins when it's set and valid, so an explicit override is honoured.
    """
    env = os.environ.get("DOTFILES_DIR")
    if env and (Path(env) / "scripts" / "lib" / "core.sh").is_file():
        return Path(env).resolve()
    return Path(__file__).resolve().parent.parent.parent


def current_platform() -> str:
    """The manifest platform key for this machine."""
    if osdetect.is_mac():
        return "macos"
    if osdetect.is_windows():
        return "windows"
    return "linux"


def package_manager() -> tuple[str, str]:
    """(manager command, human label) that owns packages on this platform.

    macOS uses Homebrew; Linux uses Nix/Home Manager (never linuxbrew); Windows
    uses Scoop. Checking for `brew` on Linux would be a guaranteed failure.
    """
    return {
        "macos":   ("brew",  "Homebrew"),
        "linux":   ("nix",   "Nix"),
        "windows": ("scoop", "Scoop"),
    }[current_platform()]


def _windows_my_documents() -> str:
    """The real Documents path — same value PowerShell's own
    [Environment]::GetFolderPath("MyDocuments") resolves to, including any
    OneDrive Known Folder Move redirection (common on corporate-managed
    machines). Read from the registry key that backs it rather than assuming
    $env:USERPROFILE\\Documents, which is wrong whenever KFM is active.
    """
    import winreg

    with winreg.OpenKey(
        winreg.HKEY_CURRENT_USER,
        r"Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders",
    ) as key:
        value, _ = winreg.QueryValueEx(key, "Personal")
    return os.path.expandvars(value)


def stow_target(entry: "mf.StowEntry") -> Path:
    """Absolute path a Stow entry lands on for this platform."""
    if not osdetect.is_windows():
        return Path.home() / entry.target

    target = entry.win_target
    # windows_target entries can be a $([Environment]::GetFolderPath(...))
    # expression (see packages.toml's powershell entry) rather than a plain
    # $env:VAR token — the substitution loop below only ever handled the
    # latter, so this resolved to the literal, non-existent expression text
    # and always reported the PowerShell profile symlink as missing.
    target = re.sub(
        r'\$\(\[Environment\]::GetFolderPath\("MyDocuments"\)\)',
        _windows_my_documents().replace("\\", "\\\\"),
        target,
    )
    for var, default in (
        ("$env:USERPROFILE",  str(Path.home())),
        ("$env:LOCALAPPDATA", os.environ.get("LOCALAPPDATA", str(Path.home()))),
        ("$env:APPDATA",      os.environ.get("APPDATA", str(Path.home()))),
    ):
        target = target.replace(var, os.environ.get(var.split(":")[1], default))
    return Path(target.replace("\\", os.sep))


def nvim_config_dir() -> Path:
    for entry in MANIFEST.stow:
        if entry.package == "nvim":
            return stow_target(entry)
    return Path.home() / ".config" / "nvim"


MANIFEST = mf.load(repo_root() / "packages.toml")


# ==============================================================================
# Colors
# ==============================================================================


class Colors:
    RED = "\033[31m"
    YELLOW = "\033[33m"
    GREEN = "\033[32m"
    BLUE = "\033[34m"
    NC = "\033[0m"

    @classmethod
    def strip(cls) -> bool:
        return not sys.stdout.isatty() or bool(os.getenv("CI"))


def _c(color: str, text: str) -> str:
    if Colors.strip():
        return text
    return f"{color}{text}{Colors.NC}"


# ==============================================================================
# Logger  (mirrors log::* from core.sh)
# ==============================================================================


class Logger:
    def _fmt(self, level: str, color: str, msg: str) -> str:
        if os.getenv("CI"):
            return msg if level in ("INFO", "SUCCESS") else f"[{level}] {msg}"
        if sys.stdout.isatty():
            return f"{color}[{level}]{Colors.NC} {msg}"
        return f"[{level}] {msg}"

    def info(self, msg: str) -> None:
        print(self._fmt("INFO", Colors.BLUE, msg))

    def success(self, msg: str) -> None:
        print(self._fmt("SUCCESS", Colors.GREEN, msg))

    def warning(self, msg: str) -> None:
        print(self._fmt("WARNING", Colors.YELLOW, msg))

    def error(self, msg: str) -> None:
        print(self._fmt("ERROR", Colors.RED, msg), file=sys.stderr)

    def fatal(self, msg: str) -> None:
        self.error(msg)
        sys.exit(1)

    def ok(self, msg: str) -> None:
        print(f"  {_c(Colors.GREEN, '✓')} {msg}")

    def warn(self, msg: str) -> None:
        print(f"  {_c(Colors.YELLOW, '⚠')} {msg}")

    def substep(self, msg: str) -> None:
        print(f"  {_c(Colors.YELLOW, '→')} {msg}")

    def kvp(self, key: str, value: str) -> None:
        print(f"  {key:<30} : {value}")

    def sep(self, width: int = 70, char: str = "─") -> None:
        print(char * width)

    def section(self, title: str, width: int = 70) -> None:
        sep = "━" * width
        if Colors.strip():
            print(f"\n{sep}\n  {title}\n{sep}")
        else:
            print(f"\n{Colors.BLUE}{sep}\n  {title}\n{sep}{Colors.NC}")

    def box(self, msg: str) -> None:
        inner = "═" * 51
        pad = " " * 51
        if Colors.strip():
            print(f"\n╔{inner}╗\n║{pad}║\n║  {msg}\n║{pad}║\n╚{inner}╝\n")
        else:
            print(
                f"\n{Colors.BLUE}╔{inner}╗\n║{pad}║\n║  {msg}\n║{pad}║"
                f"\n╚{inner}╝{Colors.NC}\n"
            )


log = Logger()


# ==============================================================================
# Data Layer
# ==============================================================================


@dataclass
class CheckResult:
    label: str
    status: Literal["pass", "warn", "fail"]
    detail: str = ""


@dataclass
class Report:
    title: str
    results: list[CheckResult] = field(default_factory=list)

    def passed(self) -> int:
        return sum(1 for r in self.results if r.status == "pass")

    def warned(self) -> int:
        return sum(1 for r in self.results if r.status == "warn")

    def failed(self) -> int:
        return sum(1 for r in self.results if r.status == "fail")

    @property
    def total(self) -> int:
        return len(self.results)

    @property
    def score(self) -> int:
        if self.total == 0:
            return 0
        return self.passed() * 100 // self.total

    @property
    def grade(self) -> str:
        pct = self.score
        if pct >= 90:
            return "EXCELLENT"
        if pct >= 75:
            return "GOOD"
        if pct >= 60:
            return "FAIR"
        return "POOR"


# ==============================================================================
# Console Renderer
# ==============================================================================


class ConsoleRenderer:
    def render_check(self, result: CheckResult) -> None:
        label_col = f"  {result.label + ':':<45} "
        if result.status == "pass":
            print(f"{label_col}{_c(Colors.GREEN, '✓ OK')}   {result.detail}")
        elif result.status == "warn":
            print(f"{label_col}{_c(Colors.YELLOW, '⚠ WARN')} {result.detail}")
        else:
            print(f"{label_col}{_c(Colors.RED, '✗ FAIL')} {result.detail}")

    def render_report(self, report: Report) -> None:
        total = report.total
        passed = report.passed()
        warned = report.warned()
        failed = report.failed()
        pct = report.score
        grade = report.grade

        if pct >= 75:
            grade_color = Colors.GREEN
        elif pct >= 60:
            grade_color = Colors.YELLOW
        else:
            grade_color = Colors.RED

        print()
        log.sep(52, "━")
        print(f"  {report.title}")
        log.sep(52, "━")
        print(f"  {_c(Colors.GREEN, '✓ Pass:')}     {passed} / {total}")
        print(f"  {_c(Colors.YELLOW, '⚠ Warn:')}     {warned} / {total}")
        print(f"  {_c(Colors.RED, '✗ Fail:')}     {failed} / {total}")
        print()
        print(f"  Score: {_c(grade_color, f'{pct}% — {grade}')}")
        print()

        if failed > 0:
            # `make install` doesn't exist on Windows — this told every failing
            # Windows check to run a command that would just error immediately.
            fix = (
                r".\scripts\setup\windows.ps1"
                if osdetect.is_windows()
                else "cd ~/dotfiles && make install"
            )
            print(f"  {_c(Colors.RED, '⚠ ACTION:')} Run: {fix}")
        elif warned > 0:
            print(f"  {_c(Colors.YELLOW, '💡 Some optional tools are missing (see above).')}")
        else:
            print(f"  {_c(Colors.GREEN, '✓ All checks passed.')}")

        print()
        log.sep(52, "━")
        print()


renderer = ConsoleRenderer()


# ==============================================================================
# Base Checker
# ==============================================================================


class SystemChecker:
    def __init__(self) -> None:
        self.results: list[CheckResult] = []

    def reset(self) -> None:
        self.results = []

    def build_report(self, title: str) -> Report:
        return Report(title=title, results=list(self.results))

    def _add(self, label: str, status: Literal["pass", "warn", "fail"], detail: str = "") -> None:
        r = CheckResult(label=label, status=status, detail=detail)
        self.results.append(r)
        renderer.render_check(r)

    def command_exists(self, cmd: str) -> bool:
        return shutil.which(cmd) is not None

    def get_version(self, cmd: str, flag: str = "--version") -> str:
        try:
            out = subprocess.run([cmd, flag], capture_output=True, text=True, timeout=5)
            combined = out.stdout or out.stderr or ""
            # Scan the first few lines, not just the first: some tools (eza,
            # AtomicParsley) lead with a tagline and print the version below it.
            for line in combined.splitlines()[:3]:
                match = re.search(r"[0-9]+\.[0-9]+(?:\.[0-9]+)?", line)
                if match:
                    return match.group(0)
            return "installed"
        except Exception:
            return "installed"

    def check_cmd(self, label: str, cmd: str, critical: bool = False, flag: str = "--version") -> None:
        if self.command_exists(cmd):
            self._add(label, "pass", f"v{self.get_version(cmd, flag)}")
        elif critical:
            self._add(label, "fail", "not installed")
        else:
            self._add(label, "warn", "not installed")

    def check_link(self, label: str, path: str, critical: bool = False) -> None:
        p = Path(path)
        if p.is_symlink():
            self._add(label, "pass", "linked")
        elif p.exists():
            self._add(label, "warn", "exists but not a symlink")
        elif critical:
            self._add(label, "fail", "not found")
        else:
            self._add(label, "warn", "not found")

    def check_condition(
        self, label: str, condition: bool, critical: bool = False, detail: str = ""
    ) -> None:
        if condition:
            self._add(label, "pass", detail)
        elif critical:
            self._add(label, "fail", detail)
        else:
            self._add(label, "warn", detail)

    @staticmethod
    def _git_config(key: str) -> str:
        try:
            result = subprocess.run(
                ["git", "config", "--global", key],
                capture_output=True, text=True, timeout=5,
            )
            return result.stdout.strip()
        except Exception:
            return ""


# ==============================================================================
# MODE: quick  (replaces mode::quick)
# ==============================================================================


class QuickHealthCheck(SystemChecker):
    def run(self) -> Report:
        self.reset()
        log.box("Dotfiles Quick Health Check")

        self._check_core()
        self._check_shell()
        self._check_neovim()
        self._check_git()
        self._check_essential_tools()

        report = self.build_report("HEALTH CHECK SUMMARY")
        renderer.render_report(report)

        if report.failed() > 0:
            print("  For full details:  make check")
            print("  For packages:      make packages")
            print("  For system info:   make sysinfo")
            print()

        return report

    def _check_core(self) -> None:
        log.section("CORE")
        dotfiles = repo_root()
        core = dotfiles / "scripts" / "lib" / "core.sh"
        self.check_condition("Dotfiles directory", dotfiles.is_dir(), critical=True,
                             detail=str(dotfiles))
        self.check_condition("Core library", core.is_file(), critical=True)
        self.check_cmd("Git", "git", critical=True)
        manager, label = package_manager()
        self.check_cmd(label, manager, critical=True)

    def _check_shell(self) -> None:
        log.section("SHELL")
        if osdetect.is_windows():
            self.check_cmd("PowerShell", "pwsh", critical=False)
            return
        home = Path.home()
        self.check_cmd("Zsh", "zsh", critical=True)
        self.check_condition("Zsh as default", "zsh" in os.environ.get("SHELL", ""))
        self.check_link(".zshenv symlink", str(home / ".zshenv"), critical=True)

    def _check_neovim(self) -> None:
        log.section("NEOVIM")
        config = nvim_config_dir()
        self.check_cmd("Neovim", "nvim")
        self.check_link("Neovim config", str(config))
        self.check_condition("init.lua", (config / "init.lua").is_file())

    def _check_git(self) -> None:
        log.section("GIT")
        home = Path.home()
        git_config_exists = (
            (home / ".config" / "git" / "config").is_file()
            or (home / ".gitconfig").is_file()
        )
        self.check_condition("Git config", git_config_exists)
        self.check_condition("Git user name", bool(self._git_config("user.name")))
        self.check_condition("Git user email", bool(self._git_config("user.email")))

    def _check_essential_tools(self) -> None:
        log.section("ESSENTIAL TOOLS")
        platform_key = current_platform()
        if platform_key != "windows":
            self.check_cmd("Tmux", "tmux", flag="-V")
        # Driven by packages.toml, so a tool added there is checked here with no
        # code change — and tools that platform doesn't ship are never checked.
        for pkg in MANIFEST.checks("quick", platform_key):
            self.check_cmd(pkg.name, pkg.binary, critical=pkg.critical,
                           flag=pkg.version_flag)


# ==============================================================================
# MODE: full  (replaces mode::full)
# ==============================================================================


class FullVerification(SystemChecker):
    def run(self) -> Report:
        self.reset()
        log.box("Full Installation Verification")

        home = Path.home()
        dotfiles = repo_root()
        platform_key = current_platform()

        log.section("DIRECTORIES")
        self.check_condition("dotfiles/", dotfiles.is_dir(), critical=True)
        self.check_condition("scripts/", (dotfiles / "scripts").is_dir(), critical=True)
        self.check_condition(".config/", (home / ".config").is_dir(), critical=True)
        # Assert the source each Stow entry points at actually exists. Checking
        # `exists()` rather than `is_dir()` keeps file entries (.zshenv,
        # .inputrc) meaningful instead of silently filtering them out — a filter
        # would make every remaining check tautologically true.
        for entry in MANIFEST.stow_for(platform_key):
            source = dotfiles / entry.repo_path
            self.check_condition(entry.repo_path, source.exists(), critical=True)

        log.section("CORE TOOLS")
        self.check_cmd("Git", "git", critical=True)
        self.check_cmd("Curl", "curl", critical=True)
        self.check_cmd("Wget", "wget")
        self.check_cmd("Make", "make")

        log.section("SHELL")
        if platform_key == "windows":
            self.check_cmd("PowerShell", "pwsh")
        else:
            self.check_cmd("Zsh", "zsh", critical=True)
            self.check_condition("Default shell", "zsh" in os.environ.get("SHELL", ""))
            self.check_link(".zshenv", str(home / ".zshenv"), critical=True)
            self.check_condition("Zsh config dir", (home / ".config" / "zsh").is_dir())

        log.section("NEOVIM")
        nvim_config = nvim_config_dir()
        self.check_cmd("Neovim", "nvim")
        self.check_link("Config link", str(nvim_config))
        self.check_condition("init.lua", (nvim_config / "init.lua").is_file())
        # Neovim keeps plugin data under one XDG-style `~/.local/share/nvim`
        # on macOS/Linux, but under a single `%LOCALAPPDATA%\nvim-data` on
        # Windows (see windows.ps1's $NVIM_DATA) — the hardcoded Unix path
        # here always false-WARNed on Windows even when lazy.nvim was
        # correctly installed.
        lazy_root = (
            Path(os.environ.get("LOCALAPPDATA", str(home))) / "nvim-data"
            if platform_key == "windows"
            else home / ".local" / "share" / "nvim"
        )
        self.check_condition("Lazy.nvim", (lazy_root / "lazy" / "lazy.nvim").is_dir())

        log.section("GIT")
        self.check_condition("Git config", (home / ".config" / "git" / "config").is_file())
        git_name = self._git_config("user.name")
        git_email = self._git_config("user.email")
        for label, val in (("Git user name", git_name), ("Git user email", git_email)):
            r = CheckResult(label, "pass", val) if val else CheckResult(label, "warn", "not set")
            self.results.append(r)
            renderer.render_check(r)

        if platform_key != "windows":
            log.section("TMUX")
            self.check_cmd("Tmux", "tmux", flag="-V")
            self.check_link("Config link", str(home / ".config" / "tmux"))
            self.check_condition("tmux.conf", (home / ".config" / "tmux" / "tmux.conf").is_file())

        # Every tool packages.toml says this platform installs. Adding a package
        # there is enough — no parallel list to update here.
        log.section("MANIFEST TOOLS")
        for pkg in MANIFEST.checks("full", platform_key):
            self.check_cmd(pkg.name, pkg.binary, critical=pkg.critical, flag=pkg.version_flag)

        log.section("DEVELOPMENT TOOLS")
        manager, manager_label = package_manager()
        self.check_cmd(manager_label, manager, critical=True)
        self.check_cmd("Python3", "python3")
        self.check_cmd("Node.js", "node")
        self.check_cmd("npm", "npm")

        log.section("SYMLINKS")
        for entry in MANIFEST.stow_for(platform_key):
            self.check_link(entry.target, str(stow_target(entry)), critical=entry.critical)

        report = self.build_report("VERIFICATION SUMMARY")
        renderer.render_report(report)
        saved = self._save_report(report)
        log.substep(f"Report saved: {saved}" if saved else "Report could not be saved")
        print()

        return report

    def _save_report(self, report: Report) -> Path | None:
        """Write a one-line summary next to the run; None if it couldn't be written.

        Uses the platform temp dir rather than a hardcoded /tmp, which does not
        exist on Windows — there the write failed silently and the caller still
        printed a path that was never created.
        """
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        path = Path(tempfile.gettempdir()) / f"dotfiles_verify_{ts}.txt"
        try:
            path.write_text(
                f"Dotfiles Verification  —  {datetime.now()}\n"
                f"User: {os.environ.get('USER', 'unknown')}  "
                f"Host: {platform.node()}  OS: {platform.system()}\n"
                f"Pass: {report.passed()}  Warn: {report.warned()}  Fail: {report.failed()}\n"
            )
        except OSError as exc:
            log.warning(f"Could not write report to {path}: {exc}")
            return None
        return path


# ==============================================================================
# MODE: packages  (replaces mode::packages)
# ==============================================================================


class PackageChecker(SystemChecker):
    """Compare what packages.toml says should be installed against reality.

    Works on all three platforms: Homebrew formulae/casks on macOS, the Home
    Manager profile on Linux, Scoop apps on Windows. Previously this was
    Homebrew-only and exited 1 outright on Linux/Windows.
    """

    def __init__(self, manifest: mf.Manifest) -> None:
        super().__init__()
        self.manifest = manifest
        self.platform = current_platform()

    def run(self) -> Report:
        self.reset()
        log.box("Package Verification")

        manager, label = package_manager()
        log.section(label.upper())
        if not self.command_exists(manager):
            log.error(f"{label} not installed — packages cannot be verified.")
            log.substep(self._install_hint())
            # Record the failure *before* building the report, so a missing
            # package manager is a reported failure rather than an empty
            # (and therefore "passing") run.
            self._add(label, "fail", "not installed")
            return self.build_report("PACKAGE SUMMARY")

        self._report_manager_version(manager, label)
        self._check_outdated(manager, label)
        print()

        expected = self.manifest.for_platform(self.platform)
        if self.platform == "macos":
            self._check_brew(expected)
        elif self.platform == "linux":
            self._check_nix(expected)
        else:
            self._check_scoop(expected)

        report = self.build_report("PACKAGE SUMMARY")
        renderer.render_report(report)

        if report.failed() > 0:
            print(f"  Install missing:  {self._install_missing_hint()}")
            print()
        print("  Maintenance:  dutils update      # upgrade everything")
        print("                dutils manifest list   # what should be installed")
        print()
        return report

    # -- helpers ---------------------------------------------------------

    def _install_hint(self) -> str:
        return {
            "macos":   'Install: /bin/bash -c "$(curl -fsSL '
                       'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
            "linux":   "Install: make nix-setup",
            "windows": "Install: powershell -File scripts/setup/windows.ps1",
        }[self.platform]

    def _install_missing_hint(self) -> str:
        return {
            "macos":   f"brew bundle --file={repo_root() / 'brew' / 'Brewfile'}",
            "linux":   "make nix-switch",
            "windows": "powershell -File scripts/setup/windows.ps1",
        }[self.platform]

    def _report_manager_version(self, manager: str, label: str) -> None:
        out = self._run([manager, "--version"])
        log.ok(out.splitlines()[0] if out.strip() else f"{label} installed")

    def _check_outdated(self, manager: str, label: str) -> None:
        if self.platform == "macos":
            outdated = [ln for ln in self._run(["brew", "outdated"]).splitlines() if ln.strip()]
        elif self.platform == "windows":
            # `scoop status` prints a table; any row past the header is an update.
            lines = [ln for ln in self._run(["scoop", "status"]).splitlines() if ln.strip()]
            outdated = lines[2:] if len(lines) > 2 else []
        else:
            # Nix pins exact derivations, so "outdated" only means the flake
            # inputs have moved — `make nix-update` is the answer, not a diff.
            log.substep("Nix pins exact versions — run `make nix-update` to refresh inputs")
            return

        if outdated:
            log.warning(f"{len(outdated)} package(s) have updates — run: dutils update")
        else:
            log.ok("All packages up to date")

    # -- per-manager checks ----------------------------------------------

    def _check_brew(self, expected: list[mf.Package]) -> None:
        formulae = [p for p in expected if not p.cask]
        casks = [p for p in expected if p.cask]

        installed = set(self._run(["brew", "list", "--formula", "-1"]).split())
        log.section("FORMULAE")
        for pkg in sorted(formulae, key=lambda p: p.name):
            short = pkg.brew.split("/")[-1]
            if short in installed:
                ver = self._run(["brew", "list", "--versions", short]).split()
                self._add(pkg.brew, "pass", ver[1] if len(ver) > 1 else "")
            else:
                self._add(pkg.brew, "fail", "missing")

        if not casks:
            return
        installed_casks = set(self._run(["brew", "list", "--cask", "-1"]).split())
        log.section("CASKS")
        for pkg in sorted(casks, key=lambda p: p.name):
            status = "pass" if pkg.brew in installed_casks else "fail"
            self._add(pkg.brew, status, "installed" if status == "pass" else "missing")

    def _check_nix(self, expected: list[mf.Package]) -> None:
        log.section("NIX PACKAGES")
        # Home Manager installs into the user profile, so the reliable signal is
        # whether the package's binary resolves — `nix profile list` shows the
        # single `home-manager-path` derivation, not its contents.
        for pkg in sorted(expected, key=lambda p: p.name):
            if not pkg.nix:
                continue
            if not pkg.binary:
                self._add(pkg.nix, "pass", "no binary to verify")
            elif self.command_exists(pkg.binary):
                self._add(pkg.nix, "pass", f"v{self.get_version(pkg.binary, pkg.version_flag)}")
            else:
                self._add(pkg.nix, "fail", "missing")

    def _check_scoop(self, expected: list[mf.Package]) -> None:
        log.section("SCOOP APPS")
        installed = {
            ln.split()[0]
            for ln in self._run(["scoop", "list"]).splitlines()
            if ln.strip() and not ln.startswith(("Name", "----", "Installed"))
        }
        for pkg in sorted(expected, key=lambda p: p.name):
            if pkg.scoop in installed:
                self._add(pkg.scoop, "pass", "installed")
            elif pkg.binary and self.command_exists(pkg.binary):
                self._add(pkg.scoop, "pass", "on PATH (not via scoop)")
            else:
                self._add(pkg.scoop, "fail", "missing")

    def _run(self, cmd: list[str]) -> str:
        try:
            return subprocess.run(cmd, capture_output=True, text=True, timeout=60).stdout or ""
        except Exception:
            return ""


# ==============================================================================
# MODE: system  (replaces mode::system)
# ==============================================================================


class SystemInfo:
    def display(self) -> None:
        log.box("System Information")
        self._show_system()
        self._show_tools()
        self._show_dotfiles()
        print()

    def _show_system(self) -> None:
        log.section("SYSTEM")
        log.kvp("Hostname", platform.node())
        log.kvp("User", os.environ.get("USER", "unknown"))
        log.kvp("OS", self._os_detail())
        log.kvp("Kernel", platform.release())
        log.kvp("Shell", os.environ.get("SHELL", "unknown"))

        if osdetect.is_mac():
            log.kvp(
                "macOS",
                self._sh("sw_vers -productVersion") + " (" + self._sh("sw_vers -buildVersion") + ")",
            )
            log.kvp("Arch", platform.machine())
            log.kvp("Model", self._sh("sysctl -n hw.model") or "unknown")
            log.kvp("CPU", self._sh("sysctl -n machdep.cpu.brand_string") or "unknown")
            log.kvp("Cores", self._sh("sysctl -n hw.ncpu") or "unknown")
            mem_str = self._sh("sysctl -n hw.memsize")
            try:
                log.kvp("Memory", f"{int(mem_str) // (1024 ** 3)} GB")
            except (ValueError, ZeroDivisionError):
                log.kvp("Memory", "unknown")

        elif osdetect.is_linux():
            os_release = Path("/etc/os-release")
            if os_release.is_file():
                info: dict[str, str] = {}
                for line in os_release.read_text().splitlines():
                    if "=" in line:
                        k, _, v = line.partition("=")
                        info[k] = v.strip('"')
                log.kvp("Distro", info.get("NAME", "unknown"))
                log.kvp("Version", info.get("VERSION_ID", "unknown"))
            log.kvp("Arch", platform.machine())
            log.kvp("CPU", self._sh("grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2").strip() or "unknown")
            log.kvp("Memory", self._sh("free -h | awk '/^Mem:/{print $2}'") or "unknown")

    def _show_tools(self) -> None:
        log.section("TOOLS")
        for t in ["git", "zsh", "nvim", "tmux", "brew", "tv", "rg", "bat", "eza", "fd", "zoxide", "jq", "python3", "node", "gh"]:
            if shutil.which(t):
                log.kvp(t, self._version(t))
            else:
                log.kvp(t, "not installed")

    def _show_dotfiles(self) -> None:
        log.section("DOTFILES")
        home = Path.home()
        log.kvp("Dotfiles dir", str(repo_root()))
        log.kvp("Config dir", str(home / ".config"))
        log.kvp("Default shell", os.environ.get("SHELL", "unknown"))
        for path, label in [
            (home / ".zshenv", "zsh"),
            (home / ".config" / "nvim", "nvim"),
            (home / ".config" / "tmux", "tmux"),
            (home / ".config" / "git", "git"),
            (home / ".config" / "zsh", "zsh config"),
        ]:
            log.kvp(f"{label} symlink", "✓ linked" if path.is_symlink() else "✗ missing")

    def _os_detail(self) -> str:
        return osdetect.detail()

    def _version(self, cmd: str) -> str:
        try:
            out = subprocess.run([cmd, "--version"], capture_output=True, text=True, timeout=5)
            first = (out.stdout or out.stderr or "").splitlines()[0] if (out.stdout or out.stderr) else ""
            m = re.search(r"[0-9]+\.[0-9]+(?:\.[0-9]+)?", first)
            return m.group(0) if m else "installed"
        except Exception:
            return "installed"

    def _sh(self, cmd: str) -> str:
        try:
            return subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=5).stdout.strip()
        except Exception:
            return ""


# ==============================================================================
# Entry Point
# ==============================================================================

USAGE = """\
Usage: check.py [MODE]

Modes:
  (none)       Quick health check (default)
  --quick      Quick health check
  --full       Full installation verification
  --packages   Compare installed packages vs packages.toml
  --system     Display system information
  --all        Run all modes
  --help, -h   Show this help
"""


def brew_vulns_summary() -> None:
    """Informational Homebrew vulnerability summary (macOS, brew 7.0+).

    Runs in the --all/diagnose flow only; never affects the exit code — the
    advisory database drifts over time, so a finding here is news to act on, not
    a broken install. Full report / filtering lives in `dutils vulns`.
    """
    import shutil
    log.section("SECURITY (brew vulns)")
    if not osdetect.is_mac():
        log.substep("macOS only (Linux uses Nix, not Homebrew) — skipped")
        return
    if shutil.which("brew") is None:
        log.substep("Homebrew not found — skipped")
        return
    if subprocess.run(["brew", "vulns", "--help"], capture_output=True).returncode != 0:
        log.substep("brew vulns unavailable (needs Homebrew 7.0+) — skipped")
        return
    log.substep("Scanning installed formulae against the advisory database…")
    out = subprocess.run(["brew", "vulns"], capture_output=True, text=True)
    text = (out.stdout or "") + (out.stderr or "")
    summary = next((ln.strip() for ln in reversed(text.splitlines())
                    if ln.strip().startswith("Found ")), None)
    if summary:
        log.substep(summary)
        log.substep("Full report: dutils vulns   (filter: dutils vulns --severity high)")
    else:
        log.substep("No known vulnerabilities reported.")


class DotfilesVerifier:
    DOTFILES_DIR = repo_root()

    def run(self, argv: list[str]) -> int:
        mode = argv[0] if argv else "--quick"

        if mode in ("--quick", "quick", ""):
            return 0 if QuickHealthCheck().run().failed() == 0 else 1

        if mode in ("--full", "full"):
            return 0 if FullVerification().run().failed() == 0 else 1

        if mode in ("--packages", "packages"):
            return 0 if PackageChecker(MANIFEST).run().failed() == 0 else 1

        if mode in ("--system", "system"):
            SystemInfo().display()
            return 0

        if mode in ("--all", "all"):
            rc = 0
            if QuickHealthCheck().run().failed() > 0:
                rc = 1
            print()
            if FullVerification().run().failed() > 0:
                rc = 1
            print()
            if PackageChecker(MANIFEST).run().failed() > 0:
                rc = 1
            print()
            SystemInfo().display()
            print()
            brew_vulns_summary()
            return rc

        if mode in ("--help", "-h", "help"):
            print(USAGE)
            return 0

        log.error(f"Unknown mode: {mode}")
        print(USAGE)
        return 1


if __name__ == "__main__":
    sys.exit(DotfilesVerifier().run(sys.argv[1:]))
