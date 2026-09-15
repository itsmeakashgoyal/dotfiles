# OSXPhotos: backing up the macOS Photos library

[osxphotos](https://github.com/RhetTbull/osxphotos) is a CLI that reads the
Photos.app library database directly and exports full-quality
originals — organized however you like, with edits, RAW pairs, burst photos,
and Live Photo videos included. It's installed automatically by `make install`
on macOS (`brew "pipx"` in `brew/Brewfile`, then `pipx install osxphotos` in
`scripts/setup/macos.sh`).

## Why not just copy files out of the `.photoslibrary` package?

Right-clicking `Photos Library.photoslibrary` → *Show Package Contents* shows
an `originals/` folder, which looks copyable — it isn't safe to rely on:

- **Edited photos** live in `resources/renders/`, not `originals/`. Copying
  only `originals/` gives you the unedited version of anything you've ever
  adjusted in Photos.
- **Live Photos** store the still image and the video separately, linked only
  via the Photos database (`database/Photos.sqlite`). Manually copying folders
  can separate these pairs.
- The internal folder layout is an Apple implementation detail that has
  changed across macOS versions and isn't meant to be read directly.

`osxphotos` reads the same database Photos.app does, so it exports the right
files with the right associations, without ever modifying the library.

## Quick reference

| Command | What it does |
| --- | --- |
| `osxphotos version` | Confirm the install worked |
| `osxphotos export --help` | Full list of export options for your installed version |

Dry run first — nothing is written, just shows what would happen:

```bash
osxphotos export ~/Desktop/PhotosBackup \
  --library "~/Pictures/Photos Library.photoslibrary" \
  --directory "{created.year}/{created.month:02d}" \
  --download-missing \
  --touch-file \
  --dry-run
```

Real export, organized into `YYYY/MM` folders by the photo/video's actual
date:

```bash
osxphotos export ~/Desktop/PhotosBackup \
  --library "~/Pictures/Photos Library.photoslibrary" \
  --directory "{created.year}/{created.month:02d}" \
  --download-missing \
  --touch-file \
  --update
```

| Flag | Effect |
| --- | --- |
| `--directory "{created.year}/{created.month:02d}"` | Sorts exports into `2024/03`, `2024/11`, etc. |
| `--download-missing` | Forces download of originals not fully stored locally (needed if iCloud Photos "Optimize Mac Storage" is on) |
| `--touch-file` | Sets each exported file's modified time to match the photo's date |
| `--update` | Safe to re-run — only exports new/changed items, no duplicates |

No `--skip-*` flags are used above, so this exports **everything** by
default: the edited version alongside the original (if you ever edited the
photo), RAW+JPEG pairs, burst-sequence photos, and the paired `.mov` for Live
Photos. Using the photo's original filename (e.g. `IMG_1234.HEIC`) is also
the default — no flag needed.

This is entirely **read-only** against the Photos library — it only ever
writes to the destination folder.

## Troubleshooting

**`brew install osxphotos` fails with "No formulae or casks found"**
→ Expected. `osxphotos` is a Python package, not a Homebrew formula — that's
why it's installed via `pipx install osxphotos` instead (handled
automatically by `scripts/setup/macos.sh`).

**`osxphotos: command not found` after install**
→ `pipx` installs shims into `~/.local/bin`, which is already on `PATH` in
this repo's zsh config (`zsh/.config/zsh/conf.d/01-exports.zsh`). Open a new
shell, or run `exec zsh`.

**`No such option '--original-name'`**
→ That flag was removed because using the original filename became the
default behavior in newer osxphotos releases. Just drop the flag — see the
commands above.

**Large iCloud download / not enough disk space**
→ If "Optimize Mac Storage" is enabled for iCloud Photos, `--download-missing`
will pull every full-resolution original down from iCloud. Make sure the Mac
running the export has enough free space and a good connection before a
first full backup.

**Re-installing/updating osxphotos manually**
→ `scripts/setup/macos.sh` only installs it if missing (to keep `make
install` safe to re-run). To upgrade to a newer version yourself:

```bash
pipx upgrade osxphotos
```
