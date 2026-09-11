#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/dutils/yt_download.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# High-quality YouTube downloader for single videos and full playlists.
#
# Thin, hardened wrapper around `yt-dlp` (+ ffmpeg) that:
#   - installs its own dependencies on macOS (Homebrew, yt-dlp, ffmpeg) on demand
#   - downloads best-available video+audio and merges to MP4 (or extracts audio)
#   - is resumable and idempotent (per-playlist download archive)
#   - validates every URL against a YouTube host allowlist before use
#
# Security notes (see adobe-security-foundations):
#   - Input validation: URLs are scheme- and host-checked against an allowlist.
#   - Injection safety: yt-dlp is invoked with an argument array and `--`; no
#     `eval`, no `shell`, no unquoted user input ever reaches a command line.
#   - Fail-closed: strict mode (`set -euo pipefail`); errors deny, never proceed.
#   - Least surprise: the Homebrew installer is only run after explicit consent.

# ------------------------------
#          INITIALIZE
# ------------------------------
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export DOTFILES_DIR
SCRIPT_DIR="${DOTFILES_DIR}/scripts"
CORE_FILE="${SCRIPT_DIR}/lib/core.sh"

# Source the shared logging library when available, otherwise fall back to
# minimal stubs so the script also runs standalone (outside the dotfiles repo).
if [[ -f "$CORE_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CORE_FILE"
else
    _c() { printf '%b\n' "$*"; }
    info() { _c "==> $*"; }
    success() { _c "[ok] $*"; }
    warning() { _c "[warn] $*" >&2; }
    error() { _c "[error] $*" >&2; }
    substep_info() { _c "    - $*"; }
    command_exists() { command -v "$1" >/dev/null 2>&1; }
fi

set -euo pipefail

# ------------------------------
#          CONFIG / DEFAULTS
# ------------------------------
readonly SCRIPT_NAME="ytd"
readonly SCRIPT_VERSION="1.0.0"

# Output root: env override, else ~/Downloads/YouTube
OUTPUT_DIR="${YT_DOWNLOAD_DIR:-$HOME/Downloads/YouTube}"

QUALITY="best" # best | 2160 | 1440 | 1080 | 720 | 480
AUDIO_ONLY="false"
AUDIO_FORMAT="m4a"   # m4a | mp3 | opus
PLAYLIST_MODE="auto" # auto | yes | no
WANT_SUBS="false"
WANT_SPONSORBLOCK="false"
COOKIES_BROWSER=""  # safari | chrome | brave | firefox | edge | ""
ARCHIVE_MODE="auto" # auto | yes | no
DRY_RUN="false"
ASSUME_YES="false"
DO_UPDATE="false"

URLS=()

# Allowlisted YouTube hosts (input validation — Rule: validate all external input)
readonly ALLOWED_HOSTS=(
    "youtube.com" "www.youtube.com" "m.youtube.com"
    "music.youtube.com" "youtu.be"
    "www.youtube-nocookie.com" "youtube-nocookie.com"
)

# ------------------------------
#          USAGE
# ------------------------------
usage() {
    cat <<EOF
${SCRIPT_NAME} v${SCRIPT_VERSION} — high-quality YouTube video & playlist downloader

USAGE:
    ${SCRIPT_NAME} [options] <url> [url ...]

DOWNLOAD OPTIONS:
    -o, --output DIR       Output directory (default: \$YT_DOWNLOAD_DIR or ~/Downloads/YouTube)
    -q, --quality VAL      Max video height: best|2160|1440|1080|720|480  (default: best)
    -a, --audio-only       Extract audio only (no video)
        --audio-format FMT Audio format for --audio-only: m4a|mp3|opus     (default: m4a)
    -p, --playlist         Force playlist mode (download every entry)
    -s, --single           Force single-video mode (ignore any playlist)
        --subs             Download and embed subtitles (incl. auto-generated, English)
        --sponsorblock     Remove sponsor/intro/outro segments via SponsorBlock
        --cookies BROWSER  Use browser cookies for private/age-gated videos
                           (safari|chrome|brave|firefox|edge)
        --archive          Force per-run download archive (skip already-downloaded)
        --no-archive       Disable the download archive

GENERAL OPTIONS:
    -n, --dry-run          List what would be downloaded; download nothing
    -y, --yes              Assume "yes" to prompts (non-interactive dependency install)
        --update           Update yt-dlp + ffmpeg to the latest version and exit
    -h, --help             Show this help and exit
    -V, --version          Show version and exit

BEHAVIOR:
    - Playlist detection is automatic: a /playlist URL downloads the whole list;
      a /watch?v=...&list=... URL downloads only that video unless --playlist is given.
    - Playlists get a resumable download archive by default; rerun the same command
      to fetch only new items.

EXAMPLES:
    dutils ${SCRIPT_NAME} 'https://youtube.com/watch?v=dQw4w9WgXcQ'
    dutils ${SCRIPT_NAME} -q 1080 'https://youtube.com/playlist?list=PLxxxx'
    dutils ${SCRIPT_NAME} -a --audio-format mp3 'https://youtu.be/dQw4w9WgXcQ'
    dutils ${SCRIPT_NAME} --subs --sponsorblock 'https://youtube.com/playlist?list=PLxxxx'
    dutils ${SCRIPT_NAME} --update
EOF
}

# ------------------------------
#          ARG PARSING
# ------------------------------
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o | --output)
                OUTPUT_DIR="${2:?--output requires a directory}"
                shift 2
                ;;
            -q | --quality)
                QUALITY="${2:?--quality requires a value}"
                shift 2
                ;;
            -a | --audio-only)
                AUDIO_ONLY="true"
                shift
                ;;
            --audio-format)
                AUDIO_FORMAT="${2:?--audio-format requires a value}"
                shift 2
                ;;
            -p | --playlist)
                PLAYLIST_MODE="yes"
                shift
                ;;
            -s | --single)
                PLAYLIST_MODE="no"
                shift
                ;;
            --subs)
                WANT_SUBS="true"
                shift
                ;;
            --sponsorblock)
                WANT_SPONSORBLOCK="true"
                shift
                ;;
            --cookies)
                COOKIES_BROWSER="${2:?--cookies requires a browser name}"
                shift 2
                ;;
            --archive)
                ARCHIVE_MODE="yes"
                shift
                ;;
            --no-archive)
                ARCHIVE_MODE="no"
                shift
                ;;
            -n | --dry-run)
                DRY_RUN="true"
                shift
                ;;
            -y | --yes)
                ASSUME_YES="true"
                shift
                ;;
            --update)
                DO_UPDATE="true"
                shift
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            -V | --version)
                printf '%s %s\n' "$SCRIPT_NAME" "$SCRIPT_VERSION"
                exit 0
                ;;
            --)
                shift
                while [[ $# -gt 0 ]]; do
                    URLS+=("$1")
                    shift
                done
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 2
                ;;
            *)
                URLS+=("$1")
                shift
                ;;
        esac
    done
}

# ------------------------------
#          VALIDATION
# ------------------------------

# Validate/normalize a single URL. Echoes the normalized URL on success,
# returns non-zero on rejection. Enforces https + host allowlist.
validate_url() {
    local url="$1" host

    # Default to https when no scheme is present (e.g. "youtu.be/xxxx").
    if [[ "$url" != *"://"* ]]; then
        url="https://${url}"
    fi

    # Only https is accepted (secure transport; no http downgrade).
    if [[ "$url" != https://* ]]; then
        error "Refusing non-HTTPS URL: $1"
        return 1
    fi

    # Extract host: strip scheme, then take up to the first / ? or #, drop creds/port.
    host="${url#https://}"
    host="${host%%[/?#]*}"
    host="${host##*@}"
    host="${host%%:*}"
    host="$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]')"

    local allowed
    for allowed in "${ALLOWED_HOSTS[@]}"; do
        if [[ "$host" == "$allowed" ]]; then
            printf '%s' "$url"
            return 0
        fi
    done

    error "Refusing URL from non-YouTube host '${host}': $1"
    return 1
}

validate_inputs() {
    # Numeric/allowlist checks on free-form options (fail-closed).
    case "$QUALITY" in
        best | 2160 | 1440 | 1080 | 720 | 480) : ;;
        *)
            error "Invalid --quality '${QUALITY}'. Use best|2160|1440|1080|720|480."
            exit 2
            ;;
    esac
    case "$AUDIO_FORMAT" in
        m4a | mp3 | opus) : ;;
        *)
            error "Invalid --audio-format '${AUDIO_FORMAT}'. Use m4a|mp3|opus."
            exit 2
            ;;
    esac
    if [[ -n "$COOKIES_BROWSER" ]]; then
        case "$COOKIES_BROWSER" in
            safari | chrome | brave | firefox | edge) : ;;
            *)
                error "Invalid --cookies browser '${COOKIES_BROWSER}'."
                exit 2
                ;;
        esac
    fi

    # Normalize every URL through the allowlist.
    local normalized=() u out
    for u in "${URLS[@]}"; do
        if out="$(validate_url "$u")"; then
            normalized+=("$out")
        else
            exit 2
        fi
    done
    URLS=("${normalized[@]}")
}

# ------------------------------
#          DEPENDENCIES
# ------------------------------

confirm() {
    # confirm "message" -> 0 yes / 1 no. Honors --yes and non-TTY (fail-closed).
    local prompt="$1" reply
    if [[ "$ASSUME_YES" == "true" ]]; then
        return 0
    fi
    if [[ ! -t 0 ]]; then
        warning "Not an interactive terminal; refusing to auto-confirm: ${prompt}"
        return 1
    fi
    read -r -p "${prompt} [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

load_brew_env() {
    # Make an already-installed brew visible in this shell session.
    if command_exists brew; then
        return 0
    fi
    local candidate
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$candidate" ]]; then
            eval "$("$candidate" shellenv)"
            return 0
        fi
    done
    return 1
}

ensure_homebrew() {
    if load_brew_env; then
        return 0
    fi

    if [[ "$(uname -s)" != "Darwin" ]]; then
        error "Homebrew not found and auto-install is macOS-only. Install brew manually: https://brew.sh"
        exit 1
    fi

    warning "Homebrew is required but not installed."
    substep_info "The official installer will run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    if ! confirm "Install Homebrew now?"; then
        error "Homebrew is required. Aborting."
        exit 1
    fi

    info "Installing Homebrew…"
    # Canonical Homebrew bootstrap over HTTPS (documented method at brew.sh).
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if ! load_brew_env; then
        error "Homebrew installation appears to have failed."
        exit 1
    fi
    success "Homebrew installed."
}

ensure_tool() {
    # ensure_tool <command> <brew-formula> [required=true]
    local cmd="$1" formula="$2" required="${3:-true}"
    if command_exists "$cmd"; then
        return 0
    fi
    info "Installing ${formula} (provides '${cmd}')…"
    if brew install "$formula"; then
        success "${formula} installed."
    else
        if [[ "$required" == "true" ]]; then
            error "Failed to install required dependency: ${formula}"
            exit 1
        fi
        warning "Optional dependency '${formula}' failed to install; continuing."
    fi
}

ensure_dependencies() {
    ensure_homebrew
    ensure_tool yt-dlp yt-dlp true
    ensure_tool ffmpeg ffmpeg true
    # AtomicParsley makes MP4 thumbnail embedding reliable; optional.
    ensure_tool AtomicParsley atomicparsley false
}

update_tools() {
    ensure_homebrew
    info "Updating Homebrew metadata…"
    brew update
    info "Upgrading yt-dlp and ffmpeg…"
    brew upgrade yt-dlp ffmpeg 2>/dev/null || true
    success "Tools are up to date."
}

# ------------------------------
#          DOWNLOAD LOGIC
# ------------------------------

# Decide playlist vs single from mode + URL shape.
resolve_playlist_flag() {
    local url="$1"
    case "$PLAYLIST_MODE" in
        yes) printf 'yes' ;;
        no) printf 'no' ;;
        auto)
            # A dedicated playlist URL -> whole list. A watch URL that merely
            # carries a &list= -> just the one video (least surprise).
            if [[ "$url" == *"/playlist"* ]]; then
                printf 'yes'
            elif [[ "$url" == *"watch?"* || "$url" == *"youtu.be/"* ]]; then
                printf 'no'
            elif [[ "$url" == *"list="* ]]; then
                printf 'yes'
            else
                printf 'no'
            fi
            ;;
    esac
}

# Build the shared yt-dlp argument array for a given playlist flag.
# Populates the global array YTDLP_ARGS.
build_ytdlp_args() {
    local is_playlist="$1"
    YTDLP_ARGS=()

    # --- Format selection ---
    if [[ "$AUDIO_ONLY" == "true" ]]; then
        YTDLP_ARGS+=(-f "bestaudio/best" -x --audio-format "$AUDIO_FORMAT" --audio-quality 0)
    else
        local fmt
        if [[ "$QUALITY" == "best" ]]; then
            fmt="bv*+ba/b"
        else
            fmt="bv*[height<=${QUALITY}]+ba/b[height<=${QUALITY}]/bv*+ba/b"
        fi
        YTDLP_ARGS+=(-f "$fmt" --merge-output-format mp4 --remux-video mp4)
    fi

    # --- Output template ---
    if [[ "$is_playlist" == "yes" ]]; then
        YTDLP_ARGS+=(--yes-playlist
            -o "${OUTPUT_DIR}/%(playlist_title|Playlist)s/%(playlist_index)02d - %(title)s.%(ext)s")
    else
        YTDLP_ARGS+=(--no-playlist
            -o "${OUTPUT_DIR}/%(title)s.%(ext)s")
    fi

    # --- Metadata / thumbnails ---
    YTDLP_ARGS+=(--embed-metadata --embed-thumbnail --add-metadata)

    # --- Subtitles ---
    if [[ "$WANT_SUBS" == "true" ]]; then
        YTDLP_ARGS+=(--write-subs --write-auto-subs --sub-langs "en.*"
            --embed-subs --convert-subs srt)
    fi

    # --- SponsorBlock ---
    if [[ "$WANT_SPONSORBLOCK" == "true" ]]; then
        YTDLP_ARGS+=(--sponsorblock-remove default)
    fi

    # --- Cookies (private / age-gated) ---
    if [[ -n "$COOKIES_BROWSER" ]]; then
        YTDLP_ARGS+=(--cookies-from-browser "$COOKIES_BROWSER")
    fi

    # --- Robustness / resumability ---
    YTDLP_ARGS+=(
        --continue
        --retries 10
        --fragment-retries 10
        --concurrent-fragments 4
        --no-overwrites
        --trim-filenames 200
    )

    # Download archive (skip already-downloaded). Default on for playlists.
    local use_archive="no"
    case "$ARCHIVE_MODE" in
        yes) use_archive="yes" ;;
        no) use_archive="no" ;;
        auto) [[ "$is_playlist" == "yes" ]] && use_archive="yes" ;;
    esac
    if [[ "$use_archive" == "yes" ]]; then
        YTDLP_ARGS+=(--download-archive "${OUTPUT_DIR}/.yt-download-archive.txt")
    fi

    # Playlists: keep going past unavailable/removed entries.
    if [[ "$is_playlist" == "yes" ]]; then
        YTDLP_ARGS+=(--ignore-errors)
    fi
}

download_one() {
    local url="$1" is_playlist
    is_playlist="$(resolve_playlist_flag "$url")"

    if [[ "$is_playlist" == "yes" ]]; then
        info "Playlist download: ${url}"
    else
        info "Single video download: ${url}"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        substep_info "Dry run — listing entries (no download):"
        local pl_flag="--no-playlist"
        [[ "$is_playlist" == "yes" ]] && pl_flag="--yes-playlist"
        # List only; do not resolve formats. `--` guards against option-like URLs.
        yt-dlp --flat-playlist --no-warnings "$pl_flag" \
            --print "%(playlist_index|1)s. %(title)s [%(id)s]" \
            -- "$url" || warning "Could not list entries for ${url}"
        return 0
    fi

    build_ytdlp_args "$is_playlist"
    # Injection-safe invocation: fixed binary, argument array, `--` terminator.
    yt-dlp "${YTDLP_ARGS[@]}" -- "$url"
}

# ------------------------------
#          MAIN
# ------------------------------
main() {
    parse_args "$@"

    if [[ "$DO_UPDATE" == "true" ]]; then
        update_tools
        exit 0
    fi

    if [[ ${#URLS[@]} -eq 0 ]]; then
        error "No URL provided."
        usage
        exit 2
    fi

    validate_inputs
    ensure_dependencies

    mkdir -p "$OUTPUT_DIR"
    info "Output directory: ${OUTPUT_DIR}"

    local url failed=0
    for url in "${URLS[@]}"; do
        if ! download_one "$url"; then
            error "Download failed for: ${url}"
            failed=$((failed + 1))
        fi
    done

    if [[ "$DRY_RUN" == "true" ]]; then
        success "Dry run complete."
    elif [[ "$failed" -eq 0 ]]; then
        success "All downloads complete → ${OUTPUT_DIR}"
    else
        error "${failed} of ${#URLS[@]} URL(s) failed."
        # HTTP 403 / "unable to download video data" almost always means a stale
        # yt-dlp: YouTube changed its player and the installed extractor is behind.
        warning "If you saw 'HTTP Error 403' or extractor errors, update and retry:"
        substep_info "dutils ${SCRIPT_NAME} --update"
        substep_info "then rerun the same command (already-downloaded items are skipped)."
        exit 1
    fi
}

main "$@"
