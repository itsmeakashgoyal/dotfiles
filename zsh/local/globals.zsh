#!/usr/bin/env zsh

# ------------------------------------------------------------------------------
# OS-Specific Configuration
# ------------------------------------------------------------------------------
# macOS-specific ulimit tweaks
if [[ "$(uname -s)" == "Darwin" ]]; then
    ulimit -n 65536 2>/dev/null # Increase max number of open files
    ulimit -u 1064 2>/dev/null  # Increase max number of user processes
fi

# ------------------------------------------------------------------------------
# Locale and Encoding
# ------------------------------------------------------------------------------
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ------------------------------------------------------------------------------
# Pager and Man Page Colors
# ------------------------------------------------------------------------------
export LESS="-iFMRX -#.25"
export LESSHISTFILE=-
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;32m'

# ------------------------------------------------------------------------------
# History Configuration
# ------------------------------------------------------------------------------
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=200000
export SAVEHIST=200000
export HISTDUP=erase

setopt append_history
setopt inc_append_history
setopt extended_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_expire_dups_first
setopt hist_reduce_blanks
setopt hist_verify
setopt hist_ignore_space
setopt hist_find_no_dups
setopt bang_hist

# ------------------------------------------------------------------------------
# Shell Behavior and Completion
# ------------------------------------------------------------------------------
setopt auto_cd
setopt auto_param_slash
setopt auto_pushd
setopt auto_resume
setopt pushd_ignore_dups
setopt pushd_silent
setopt clobber
setopt extended_glob
setopt glob_dots
setopt ignore_eof
setopt interactive_comments
setopt magic_equal_subst
setopt nonomatch
setopt notify
setopt numeric_glob_sort
setopt print_exit_value
setopt prompt_subst
setopt no_flow_control
setopt list_packed

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
# FZF-TAB Configuration
# ------------------------------------------------------------------------------
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup      # Use tmux popup for fzf UI
zstyle ':fzf-tab:*' popup-min-size 50 8             # Minimum popup size (cols, rows)
zstyle ':fzf-tab:*' popup-pad 30 0                  # Horizontal padding for popup
zstyle ':fzf-tab:*' fzf-flags '--color=bg+:23'      # Custom color tweak for highlight
zstyle ':fzf-tab:*' continuous-trigger 'ctrl-space' # Trigger fzf-tab repeatedly with Ctrl+Space

# Previews for various completion types
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --icons --level=2 --color=always $realpath'
zstyle ':fzf-tab:complete:nvim:*' fzf-preview 'bat --color=always --style=numbers $realpath'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
  fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

# ------------------------------------------------------------------------------
# Basic Completion Settings
# ------------------------------------------------------------------------------
# Enable caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
# zstyle :compinstall filename "$ZDOTDIR/.zshrc"

# Hide unnecessary files
zstyle ':completion:*' ignored-patterns '.DS_Store|*/.git' # Hide unwanted files

# Flexible matching: case-insensitive, underscore-dash, substring, etc.
zstyle ':completion:*' matcher-list '' \
  '+m:{[:lower:]}={[:upper:]}' \
  '+m:{[:upper:]}={[:lower:]}' \
  '+m:{_-}={-_}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

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
