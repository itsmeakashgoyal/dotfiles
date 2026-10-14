#!/usr/bin/env python3
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/organize_media.py
# ░▓▓▓▓▓▓▓▓▓▓
#
# Sorts a flat folder of photo/video backups into <dest>/<year>/<month>/ by
# the media's actual creation date (month as a name, e.g. "2024/September/",
# not split into Photos/Videos subfolders).
#
# This is deliberately separate from the osxphotos workflow (docs/OSXPHOTOS.md):
# osxphotos reads Photos.app's library database to export originals, which only
# works against an actual `.photoslibrary`. This script is for folders that are
# already just loose files with no such database - e.g. a Screenshots/exports
# backup synced between Macs.
#
# Date priority (best to worst):
#   1. Embedded media metadata - EXIF DateTimeOriginal/CreateDate for photos,
#      QuickTime CreateDate/MediaCreateDate/TrackCreateDate for videos - read
#      via `exiftool` (offered as a one-time `brew install` if missing).
#   2. Filesystem birth time (st_birthtime, macOS/BSD) for files exiftool
#      couldn't find a date in, or when exiftool isn't available at all.

import argparse
import json
import os
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "lib"))
from dutil import ok, info, step, warn, fail, confirm  # noqa: E402

SCRIPT_NAME = "organize-media"

PHOTO_EXTS = {
    "png", "jpg", "jpeg", "heic", "heif", "gif", "tif", "tiff", "bmp", "webp",
    "raw", "cr2", "cr3", "nef", "arw", "dng", "orf", "rw2",
}
VIDEO_EXTS = {
    "mov", "mp4", "m4v", "avi", "mkv", "3gp", "3g2", "webm", "mts", "m2ts",
}

# Priority order of exiftool tags to try per file - first non-empty one wins.
# DateTimeOriginal/CreateDate cover EXIF photos; MediaCreateDate/TrackCreateDate
# are QuickTime-specific fallbacks some screen recordings only populate.
METADATA_DATE_TAGS = ["DateTimeOriginal", "CreateDate", "MediaCreateDate", "TrackCreateDate"]
METADATA_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"
EXIFTOOL_BATCH_SIZE = 300


def _is_year_dir(name: str) -> bool:
    """Matches folders this script itself creates (e.g. "2024"), so a
    recursive re-run never descends into already-organized output."""
    return len(name) == 4 and name.isdigit()


def ensure_exiftool(auto_yes: bool) -> bool:
    """Return True if exiftool is (or becomes) available on PATH."""
    if shutil.which("exiftool"):
        return True
    if shutil.which("brew") is None:
        warn("exiftool not found and Homebrew isn't available to install it.")
        return False
    if not auto_yes and not confirm(
        "exiftool isn't installed. Install it now via Homebrew to read "
        "photo/video creation-date metadata?"
    ):
        return False
    info("Installing exiftool…")
    if subprocess.run(["brew", "install", "exiftool"], check=False).returncode != 0:
        warn("Failed to install exiftool.")
        return False
    if shutil.which("exiftool") is None:
        return False
    ok("exiftool installed.")
    return True


def read_metadata_dates(paths: list[Path]) -> dict[Path, datetime]:
    """Batch-read each file's embedded creation date via exiftool. Missing
    entries mean exiftool found no usable date tag for that file."""
    dates: dict[Path, datetime] = {}
    for i in range(0, len(paths), EXIFTOOL_BATCH_SIZE):
        batch = paths[i:i + EXIFTOOL_BATCH_SIZE]
        cmd = [
            "exiftool", "-json",
            "-api", "QuickTimeUTC=1",  # QuickTime dates are UTC; convert to local
            "-d", METADATA_DATE_FORMAT,
            *[f"-{tag}" for tag in METADATA_DATE_TAGS],
            "--", *[str(p) for p in batch],
        ]
        proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
        if not proc.stdout:
            continue
        try:
            entries = json.loads(proc.stdout)
        except json.JSONDecodeError:
            continue
        for entry in entries:
            source = entry.get("SourceFile")
            if not source:
                continue
            for tag in METADATA_DATE_TAGS:
                value = entry.get(tag)
                if not value:
                    continue
                try:
                    dates[Path(source)] = datetime.strptime(value, METADATA_DATE_FORMAT)
                    break
                except ValueError:
                    continue
    return dates


def filesystem_date(path: Path) -> datetime:
    st = path.stat()
    # st_birthtime is macOS/BSD-only; APFS/HFS+ preserve it across copies far
    # more reliably than mtime, which Finder/AirDrop/zip can reset. Only fall
    # back to mtime if birth time genuinely isn't available on this platform.
    birth = getattr(st, "st_birthtime", None)
    if birth:
        return datetime.fromtimestamp(birth)
    return datetime.fromtimestamp(st.st_mtime)


def classify(path: Path) -> str:
    """Photo/Video/Other - used only for the summary counts printed to the
    user, not for the destination folder layout (no Photos/Videos split)."""
    ext = path.suffix.lower().lstrip(".")
    if ext in PHOTO_EXTS:
        return "Photos"
    if ext in VIDEO_EXTS:
        return "Videos"
    return "Other"


def month_label(dt: datetime, month_format: str) -> str:
    return dt.strftime("%m") if month_format == "number" else dt.strftime("%B")


def unique_destination(dest: Path) -> Path:
    """Never overwrite: append " (2)", " (3)", ... on a name collision."""
    if not dest.exists():
        return dest
    stem, suffix, parent = dest.stem, dest.suffix, dest.parent
    n = 2
    while True:
        candidate = parent / f"{stem} ({n}){suffix}"
        if not candidate.exists():
            return candidate
        n += 1


def iter_candidates(source: Path, recursive: bool):
    if not recursive:
        for entry in sorted(source.iterdir()):
            if entry.is_file() and not entry.name.startswith("."):
                yield entry
        return

    for root, dirnames, filenames in os.walk(source):
        dirnames[:] = sorted(
            d for d in dirnames if not d.startswith(".") and not _is_year_dir(d)
        )
        for name in sorted(filenames):
            if not name.startswith("."):
                yield Path(root) / name


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog=f"dutils {SCRIPT_NAME}",
        description="Sort a flat photo/video backup folder into year/month folders by media creation date.",
        epilog=(
            "Examples:\n"
            "  dutils organize-media ~/Workspace/Screenshots --dry-run\n"
            "  dutils organize-media ~/Workspace/Screenshots\n"
            "  dutils organize-media ~/Workspace/Screenshots --dest ~/Pictures/Sorted --copy\n"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("source", help="Folder containing the flat photo/video backup")
    parser.add_argument(
        "--dest",
        help="Destination root (default: reorganize in place inside <source>)",
    )
    parser.add_argument(
        "--copy", action="store_true",
        help="Copy instead of move (default: move, i.e. reorganize in place)",
    )
    parser.add_argument(
        "--recursive", action="store_true",
        help="Also pull files out of existing subfolders (default: top-level files only)",
    )
    parser.add_argument(
        "--date-source", choices=["metadata", "birth"], default="metadata",
        help=(
            "Date to bucket by: 'metadata' uses the media's embedded creation "
            "date (EXIF/QuickTime, via exiftool), falling back to filesystem "
            "birth time per-file when a file has none; 'birth' skips metadata "
            "and always uses filesystem birth time (default: metadata)"
        ),
    )
    parser.add_argument(
        "--month-format", choices=["name", "number"], default="name",
        help="Month folder as a name like 'September' or zero-padded number like '09' (default: name)",
    )
    parser.add_argument("-n", "--dry-run", action="store_true", help="Preview only, write nothing")
    parser.add_argument("-y", "--yes", action="store_true", help="Skip confirmation prompts (move + exiftool install)")
    return parser


def main(argv: list[str] | None = None) -> None:
    args = build_parser().parse_args(argv)

    source = Path(args.source).expanduser().resolve()
    if not source.is_dir():
        fail(f"Not a directory: {source}")
        sys.exit(1)

    dest_root = Path(args.dest).expanduser().resolve() if args.dest else source

    candidates = list(iter_candidates(source, args.recursive))
    if not candidates:
        info("No files to organize.")
        return

    metadata_dates: dict[Path, datetime] = {}
    if args.date_source == "metadata":
        if ensure_exiftool(args.yes):
            info(f"Reading media creation dates for {len(candidates)} file(s)…")
            metadata_dates = read_metadata_dates(candidates)
        else:
            warn("Falling back to filesystem birth time for every file.")

    plan = []
    counts: dict[str, int] = {}
    fallback_count = 0
    for path in candidates:
        dt = metadata_dates.get(path)
        if dt is None:
            dt = filesystem_date(path)
            if args.date_source == "metadata":
                fallback_count += 1
        category = classify(path)
        target = dest_root / f"{dt.year:04d}" / month_label(dt, args.month_format) / path.name
        plan.append((path, target))
        counts[category] = counts.get(category, 0) + 1

    verb = "Copy" if args.copy else "Move"
    info(f"{verb} plan: {len(plan)} file(s) from {source}")
    for category, n in sorted(counts.items()):
        step(f"{category}: {n} file(s)")
    if args.date_source == "metadata" and fallback_count:
        step(f"{fallback_count} file(s) had no media creation metadata - used filesystem date instead")
    if "Other" in counts:
        warn("Files counted under \"Other\" have an extension this script doesn't recognize as photo/video (they're still organized by date).")

    if args.dry_run:
        for path, target in plan:
            print(f"  {path}  ->  {target}")
        info("Dry run only - nothing was written.")
        return

    if not args.yes:
        action = "copy" if args.copy else "move"
        if not confirm(f"{action.capitalize()} {len(plan)} file(s) into {dest_root}?"):
            warn("Aborted.")
            return

    moved = 0
    failed = 0
    for path, target in plan:
        target.parent.mkdir(parents=True, exist_ok=True)
        final_target = unique_destination(target)
        try:
            if args.copy:
                shutil.copy2(path, final_target)
            else:
                shutil.move(str(path), str(final_target))
            moved += 1
        except OSError as exc:
            fail(f"{path.name}: {exc}")
            failed += 1

    if failed:
        warn(f"{moved} file(s) organized, {failed} failed.")
        sys.exit(1)
    ok(f"{moved} file(s) organized into {dest_root}")


if __name__ == "__main__":
    main(sys.argv[1:])
