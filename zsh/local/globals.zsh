#!/usr/bin/env zsh

if [[ $(uname -s) = Darwin ]]; then
  # Override insanely low open file limits on macOS.
  ulimit -n 65536  # Increase max number of open files
  ulimit -u 1064   # Increase max number of user processes
fi

# ------------------------------------------------------------------------------
# Language and Locale Settings
# ------------------------------------------------------------------------------
export LC_COLLATE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LC_MONETARY=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8
export LC_TIME=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# i = case-insensitive searches, unless uppercase characters in search string
# F = exit immediately if output fits on one screen
# M = verbose prompt
# R = ANSI color support
# X = suppress alternate screen
# -#.25 = scroll horizontally by quarter of screen width (default is half)
export LESS="-iFMRX -#.25"

# Colorful man pages
export LESS_TERMCAP_mb=$'\e[1;31m'   # begin bold
export LESS_TERMCAP_md=$'\e[1;31m'   # begin double-bright mode
export LESS_TERMCAP_me=$'\e[0m'      # end all mode
export LESS_TERMCAP_se=$'\e[0m'      # end standout-mode
export LESS_TERMCAP_so=$'\e[01;33m'  # begin standout-mode
export LESS_TERMCAP_ue=$'\e[0m'      # end underline
export LESS_TERMCAP_us=$'\e[1;4;32m' # begin underline

# ------------------------------------------------------------------------------
# History Configuration
# ------------------------------------------------------------------------------
# History file location and size
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=130000 # Internal history list size
export SAVEHIST=100000 # History file size
export HISTDUP=erase   # Erase duplicates in history
export LESSHISTFILE=-
# HIST_STAMPS=yyyy/mm/dd

# History Options
setopt append_history # Append to history file
setopt extended_history
setopt hist_expire_dups_first
setopt share_history           # Share history between sessions
setopt hist_reduce_blanks      # Remove unnecessary blanks
setopt hist_ignore_all_dups    # Remove older duplicate entries
setopt hist_save_no_dups       # Don't save duplicates
setopt inc_append_history      # Add commands immediately
setopt bang_hist               # Enable history expansion
setopt NO_HIST_IGNORE_ALL_DUPS # don't filter non-contiguous duplicates from history
setopt HIST_FIND_NO_DUPS       # don't show dupes when searching
setopt HIST_IGNORE_DUPS        # do filter contiguous duplicates from history
setopt HIST_IGNORE_SPACE       # [default] don't record commands starting with a space
setopt HIST_VERIFY             # confirm history expansion (!$, !!, !foo)

# ------------------------------------------------------------------------------
# Shell Options
# ------------------------------------------------------------------------------
setopt glob_dots            # Include dotfiles in globbing
setopt extended_glob        # Extended globbing capabilities
setopt NO_HUP               # Don't kill background jobs on exit
setopt magicequalsubst      # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch            # hide error message if there is no match for the pattern
setopt notify               # report the status of background jobs immediately
setopt numericglobsort      # sort filenames numerically when it makes sense
setopt promptsubst          # enable command substitution in prompt
setopt AUTO_CD              # [default] .. is shortcut for cd .. (etc)
setopt AUTO_PARAM_SLASH     # tab completing directory appends a slash
setopt AUTO_PUSHD           # [default] cd automatically pushes old dir onto dir stack
setopt AUTO_RESUME          # allow simple commands to resume backgrounded jobs
setopt CLOBBER              # allow clobbering with >, no need to use >!
setopt CORRECT              # [default] command auto-correction
setopt CORRECT_ALL          # [default] argument auto-correction
setopt NO_FLOW_CONTROL      # disable start (C-s) and stop (C-q) characters
setopt IGNORE_EOF           # [default] prevent accidental C-d from exiting shell
setopt INTERACTIVE_COMMENTS # [default] allow comments, even in interactive shells
setopt LIST_PACKED          # make completion lists more densely packed
setopt MENU_COMPLETE        # auto-insert first possible ambiguous completion
setopt NO_NOMATCH           # [default] unmatched patterns are left unchanged
setopt PRINT_EXIT_VALUE     # [default] for non-zero exit status
setopt PUSHD_IGNORE_DUPS    # don't push multiple copies of same dir onto stack
setopt PUSHD_SILENT         # [default] don't print dir stack after pushing/popping
setopt SHARE_HISTORY        # share history across shells

# Eza colors: https://github.com/eza-community/eza/blob/main/man/eza_colors.5.md
# ------------------------------------------------------------------------------
# Eza Configuration
# ------------------------------------------------------------------------------
# Icons and colors for different file types
export EZA_COLORS="
di=34:                    # Directories (blue)
fi=0:                     # Files (default)
ex=32:                    # Executables (green)
ln=36:                    # Symlinks (cyan)
or=31:                    # Broken symlinks (red)
bd=33:                    # Block devices (yellow)
cd=33:                    # Character devices (yellow)
so=35:                    # Sockets (magenta)
pi=35:                    # Pipes (magenta)

# Permissions
ur=38;5;250:             # User read
uw=38;5;250:             # User write
ux=38;5;250:             # User execute
ue=38;5;250:             # User special
gr=38;5;245:             # Group read
gw=38;5;245:             # Group write
gx=38;5;245:             # Group execute
ge=38;5;245:             # Group special
tr=38;5;240:             # Others read
tw=38;5;240:             # Others write
tx=38;5;240:             # Others execute
te=38;5;240:             # Others special

# Size colors
sn=32:                   # Size numbers (green)
sb=32:                   # Size unit (green)
nb=32:                   # Allocated size numbers
nk=32:                   # Allocated size unit

# Git status colors
ga=32:                   # New
gm=33:                   # Modified
gd=31:                   # Deleted
gv=36:                   # Renamed

# File types and extensions
*.zip=38;5;214:         # Archives
*.tar=38;5;214:
*.gz=38;5;214:
*.rar=38;5;214:
*.7z=38;5;214:

*.pdf=38;5;203:         # Documents
*.md=38;5;123:
*.txt=38;5;123:
*.doc=38;5;123:
*.docx=38;5;123:

*.mp3=38;5;135:         # Media
*.wav=38;5;135:
*.mp4=38;5;135:
*.mov=38;5;135:

*.jpg=38;5;205:         # Images
*.jpeg=38;5;205:
*.png=38;5;205:
*.gif=38;5;205:
*.svg=38;5;205:

*.vim=38;5;156:         # Code
*.zsh=38;5;156:
*.sh=38;5;156:
*.py=38;5;156:
*.js=38;5;156:
*.rb=38;5;156:
*.rs=38;5;156:
*.go=38;5;156:

# Special files
.git=38;5;197:          # Git directory
.gitignore=38;5;197:    # Git ignore file
Dockerfile=38;5;222:    # Docker files
docker-compose.yml=38;5;222:
"

# ------------------------------------------------------------------------------
# Basic Completion Settings
# ------------------------------------------------------------------------------
# Enable caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
# zstyle :compinstall filename "$ZDOTDIR/.zshrc"

# Hide unnecessary files
zstyle ':completion:*' ignored-patterns '.|..|.DS_Store|**/.|**/..|**/.DS_Store|**/.git'

# Make completion:
# - Try exact (case-sensitive) match first.
# - Then fall back to case-insensitive.
# - Accept abbreviations after . or _ or - (ie. f.b -> foo.bar).
# - Substring complete (ie. bar -> foobar).
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}' '+m:{_-}={-_}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Colorize completions using default `ls` colors.
zstyle ':completion:*' list-colors ''

# Allow completion of ..<Tab> to ../ and beyond.
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(..) ]] && reply=(..)'

# $CDPATH is overpowered (can allow us to jump to 100s of directories) so tends
# to dominate completion; exclude path-directories from the tag-order so that
# they will only be used as a fallback if no completions are found.
zstyle ':completion:*:complete:(cd|pushd):*' tag-order 'local-directories named-directories'

# Categorize completion suggestions with headings:
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format %F{default}%B%{$__AKASH[ITALIC_ON]%}--- %d ---%{$__AKASH[ITALIC_OFF]%}%b%f

# Enable keyboard navigation of completions in menu
# (not just tab/shift-tab but cursor keys as well):
zstyle ':completion:*' menu select
