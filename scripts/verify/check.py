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
#   check.py --packages   # compare installed packages vs Brewfile
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
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Literal

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
import osdetect  # noqa: E402


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
            print(f"  {_c(Colors.RED, '⚠ ACTION:')} Run: cd ~/dotfiles && make install")
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
            first_line = combined.splitlines()[0] if combined.splitlines() else ""
            match = re.search(r"[0-9]+\.[0-9]+(?:\.[0-9]+)?", first_line)
            return match.group(0) if match else "installed"
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
        home = Path.home()
        dotfiles = home / "dotfiles"
        core = dotfiles / "scripts" / "lib" / "core.sh"
        self.check_condition("Dotfiles directory", dotfiles.is_dir(), critical=True)
        self.check_condition("Core library", core.is_file(), critical=True)
        self.check_cmd("Git", "git", critical=True)
        self.check_cmd("Homebrew", "brew", critical=True)

    def _check_shell(self) -> None:
        log.section("SHELL")
        home = Path.home()
        self.check_cmd("Zsh", "zsh", critical=True)
        self.check_condition("Zsh as default", "zsh" in os.environ.get("SHELL", ""))
        self.check_link(".zshenv symlink", str(home / ".zshenv"), critical=True)

    def _check_neovim(self) -> None:
        log.section("NEOVIM")
        home = Path.home()
        self.check_cmd("Neovim", "nvim")
        self.check_link("Neovim config", str(home / ".config" / "nvim"))
        self.check_condition("init.lua", (home / ".config" / "nvim" / "init.lua").is_file())

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
        self.check_cmd("Tmux", "tmux")
        self.check_cmd("television", "tv")
        self.check_cmd("ripgrep", "rg")
        self.check_cmd("bat", "bat")
        self.check_cmd("eza", "eza")
        self.check_cmd("zoxide", "zoxide")


# ==============================================================================
# MODE: full  (replaces mode::full)
# ==============================================================================


class FullVerification(SystemChecker):
    def run(self) -> Report:
        self.reset()
        log.box("Full Installation Verification")

        home = Path.home()

        log.section("DIRECTORIES")
        for d in [
            home / "dotfiles",
            home / "dotfiles" / "zsh" / ".config" / "zsh",
            home / "dotfiles" / "nvim" / ".config" / "nvim",
            home / "dotfiles" / "tmux" / ".config" / "tmux",
            home / "dotfiles" / "scripts",
            home / ".config",
        ]:
            self.check_condition(f"{d.name}/", d.is_dir(), critical=True)

        log.section("CORE TOOLS")
        self.check_cmd("Git", "git", critical=True)
        self.check_cmd("Curl", "curl", critical=True)
        self.check_cmd("Wget", "wget")
        self.check_cmd("Make", "make")

        log.section("SHELL")
        self.check_cmd("Zsh", "zsh", critical=True)
        self.check_condition("Default shell", "zsh" in os.environ.get("SHELL", ""))
        self.check_link(".zshenv", str(home / ".zshenv"), critical=True)
        self.check_condition("Zsh config dir", (home / ".config" / "zsh").is_dir())

        log.section("NEOVIM")
        self.check_cmd("Neovim", "nvim")
        self.check_link("Config link", str(home / ".config" / "nvim"))
        self.check_condition("init.lua", (home / ".config" / "nvim" / "init.lua").is_file())
        self.check_condition(
            "Lazy.nvim",
            (home / ".local" / "share" / "nvim" / "lazy" / "lazy.nvim").is_dir(),
        )

        log.section("GIT")
        self.check_condition("Git config", (home / ".config" / "git" / "config").is_file())
        git_name = self._git_config("user.name")
        git_email = self._git_config("user.email")
        for label, val in (("Git user name", git_name), ("Git user email", git_email)):
            r = CheckResult(label, "pass", val) if val else CheckResult(label, "warn", "not set")
            self.results.append(r)
            renderer.render_check(r)
        self.check_cmd("delta", "delta")
        self.check_cmd("lazygit", "lazygit")

        log.section("TMUX")
        self.check_cmd("Tmux", "tmux", flag="-V")
        self.check_link("Config link", str(home / ".config" / "tmux"))
        self.check_condition("tmux.conf", (home / ".config" / "tmux" / "tmux.conf").is_file())

        log.section("MODERN CLI TOOLS")
        for cmd in ["bat", "eza", "rg", "fd", "tv", "zoxide", "jq"]:
            self.check_cmd(cmd, cmd)

        log.section("DEVELOPMENT TOOLS")
        self.check_cmd("Homebrew", "brew", critical=True)
        self.check_cmd("Python3", "python3")
        self.check_cmd("Node.js", "node")
        self.check_cmd("npm", "npm")
        self.check_cmd("gh", "gh")

        log.section("SYMLINKS")
        for lnk in [
            home / ".zshenv",
            home / ".config" / "nvim",
            home / ".config" / "tmux",
            home / ".config" / "git",
            home / ".config" / "zsh",
        ]:
            self.check_link(lnk.name, str(lnk))

        report = self.build_report("VERIFICATION SUMMARY")
        renderer.render_report(report)
        log.substep(f"Report saved: {self._save_report(report)}")
        print()

        return report

    def _save_report(self, report: Report) -> Path:
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        path = Path(f"/tmp/dotfiles_verify_{ts}.txt")
        try:
            path.write_text(
                f"Dotfiles Verification  —  {datetime.now()}\n"
                f"User: {os.environ.get('USER', 'unknown')}  "
                f"Host: {platform.node()}  OS: {platform.system()}\n"
                f"Pass: {report.passed()}  Warn: {report.warned()}  Fail: {report.failed()}\n"
            )
        except Exception:
            pass
        return path


# ==============================================================================
# MODE: packages  (replaces mode::packages)
# ==============================================================================


class PackageChecker(SystemChecker):
    def __init__(self, brewfile: Path) -> None:
        super().__init__()
        self.brewfile = brewfile

    def run(self) -> Report:
        self.reset()
        log.box("Package Verification")

        log.section("HOMEBREW")
        if not self.command_exists("brew"):
            log.error("Homebrew not installed — install with:")
            print(
                '  /bin/bash -c "$(curl -fsSL'
                " https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            )
            sys.exit(1)

        brew_ver = self._run(["brew", "--version"])
        log.ok(brew_ver.splitlines()[0] if brew_ver else "Homebrew installed")

        outdated = self._run(["brew", "outdated"])
        if not outdated.strip():
            log.ok("All packages up to date")
        else:
            cnt = len([ln for ln in outdated.strip().splitlines() if ln])
            log.warning(f"{cnt} package(s) have updates — run: brew upgrade")
        print()

        if not self.brewfile.is_file():
            log.error(f"Brewfile not found at {self.brewfile}")
            sys.exit(1)

        parsed = self._parse_brewfile()

        self._check_taps(parsed.get("tap", []))
        self._check_formulae(parsed.get("brew", []))
        if osdetect.is_mac():
            self._check_casks(parsed.get("cask", []))

        report = self.build_report("PACKAGE SUMMARY")
        renderer.render_report(report)

        if report.failed() > 0:
            print(f"  Install missing:  brew bundle --file={self.brewfile}")
            print()

        print("  Maintenance tips:")
        print("    brew update && brew upgrade   # update all")
        print("    brew cleanup                  # remove old versions")
        print("    brew doctor                   # check for issues")
        print()

        return report

    def _check_taps(self, taps: list[str]) -> None:
        log.section("TAPS")
        if not taps:
            log.substep("No taps in Brewfile")
            return
        installed = set(self._run(["brew", "tap"]).splitlines())
        for tap in taps:
            if tap in installed:
                self._add(tap, "pass", "tapped")
            else:
                self._add(tap, "fail", "not tapped")

    def _check_formulae(self, formulae: list[str]) -> None:
        log.section("FORMULAE")
        if not formulae:
            log.substep("No formulae in Brewfile")
            return
        for f in formulae:
            result = subprocess.run(
                ["brew", "list", "--formula", f], capture_output=True, text=True
            )
            if result.returncode == 0:
                ver_parts = self._run(["brew", "list", "--versions", f]).split()
                ver = ver_parts[1] if len(ver_parts) > 1 else ""
                self._add(f, "pass", ver)
            else:
                self._add(f, "fail", "missing")

    def _check_casks(self, casks: list[str]) -> None:
        log.section("CASKS")
        if not casks:
            log.substep("No casks in Brewfile")
            return
        for c in casks:
            result = subprocess.run(
                ["brew", "list", "--cask", c], capture_output=True, text=True
            )
            if result.returncode == 0:
                self._add(c, "pass", "installed")
            else:
                self._add(c, "fail", "missing")

    def _parse_brewfile(self) -> dict[str, list[str]]:
        result: dict[str, list[str]] = {"tap": [], "brew": [], "cask": []}
        try:
            text = self.brewfile.read_text()
        except Exception:
            return result
        for line in text.splitlines():
            line = line.strip()
            for key in ("tap", "brew", "cask"):
                if line.startswith(f"{key} "):
                    m = re.search(r"""['"]([^'"]+)['"]""", line)
                    if m:
                        result[key].append(m.group(1))
                    break
        return result

    def _run(self, cmd: list[str]) -> str:
        try:
            return subprocess.run(cmd, capture_output=True, text=True, timeout=30).stdout or ""
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
        log.kvp("Dotfiles dir", str(home / "dotfiles"))
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
  --packages   Compare installed packages vs Brewfile
  --system     Display system information
  --all        Run all modes
  --help, -h   Show this help
"""


class DotfilesVerifier:
    DOTFILES_DIR = Path.home() / "dotfiles"

    def run(self, argv: list[str]) -> int:
        mode = argv[0] if argv else "--quick"

        if mode in ("--quick", "quick", ""):
            return 0 if QuickHealthCheck().run().failed() == 0 else 1

        if mode in ("--full", "full"):
            return 0 if FullVerification().run().failed() == 0 else 1

        if mode in ("--packages", "packages"):
            brewfile = self.DOTFILES_DIR / "packages" / "Brewfile"
            return 0 if PackageChecker(brewfile).run().failed() == 0 else 1

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
            brewfile = self.DOTFILES_DIR / "packages" / "Brewfile"
            if PackageChecker(brewfile).run().failed() > 0:
                rc = 1
            print()
            SystemInfo().display()
            return rc

        if mode in ("--help", "-h", "help"):
            print(USAGE)
            return 0

        log.error(f"Unknown mode: {mode}")
        print(USAGE)
        return 1


if __name__ == "__main__":
    sys.exit(DotfilesVerifier().run(sys.argv[1:]))
