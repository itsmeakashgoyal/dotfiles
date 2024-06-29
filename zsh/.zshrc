# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'mac'

# Don't start tmux.
zstyle ':z4h:' start-tmux       no

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'no'

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'no'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4h init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/bin $path)

# Export environment variables.
export GPG_TTY=$TTY

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It does nothing useful.
z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

# Define key bindings.
z4h bindkey undo Ctrl+/   Shift+Tab  # undo the last command line change
z4h bindkey redo Option+/            # redo the last undone command line change

z4h bindkey z4h-cd-back    Shift+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Shift+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Shift+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Shift+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Define aliases.
alias tree='tree -a -I .git'

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

# Akash's configuration
if [ -x "$(command -v fzf)"  ]
then
    # Append this line to ~/.zshrc to enable fzf keybindings for Zsh:
    source /home/ir/.fzf/shell/key-bindings.zsh
    # Append this line to ~/.zshrc to enable fuzzy auto-completion for Zsh:
    source /home/ir/.fzf/shell/completion.zsh
fi

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

export FZF_DEFAULT_OPTS="--height=50% --min-height=15 --reverse"
export FZF_DEFAULT_OPTS='--layout=reverse'
# export FZF_DEFAULT_COMMAND='rg --files'

export FZF_CTRL_T_OPTS="--height 60% \
 --border sharp \
 --layout reverse \
 --prompt '∷ ' \
 --pointer ▶ \
 --marker ⇒"

# colorful man pages
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;31m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;32m'

## export PATH
export PATH=/home/ir/.local/bin:$PATH
export PATH=$PATH:/home/ir/.local/bin:/home/ir/.fzf/bin
export PATH=$PATH:~/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
export PATH=$PATH:/usr/local/bin/clang-15:/usr/local/compilers/clang15/bin
export PATH=$PATH:$HOME/.local/share/gem/ruby/3.0.0/bin
# ~/.config/tmux/plugins
export PATH=$PATH:$HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin


# the detailed meaning of the below three variable can be found in `man zshparam`.
HISTSIZE=1000000  # the number of items for the internal history list
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE  # maximum number of items for the history file
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups # do not put duplicated command into history list
setopt hist_save_no_dups  # do not save duplicated command
setopt hist_ignore_dups
setopt hist_find_no_dups
# setopt EXTENDED_HISTORY  # record command start time

# Define aliases.
alias tree='tree -a -I .git'

source $(dirname $(gem which colorls))/tab_complete.sh
alias ls='colorls'
alias ll='colorls -lrti'
alias la='colorls -lrtia'
alias lt='colorls -t -1'       ## Sort by modification time

# Add flags to existing aliases.
# alias ls='ls -p --group-directories-first --color=auto'
# alias ls="${aliases[ls]:-ls} -A"
# alias ll='ls -ailF'
# alias la='ls -A'
# alias l='ls -CF'
alias setdev='~/dotfiles-dev/extras/setup_vscode.sh'
alias setdevc='~/dotfiles-dev/extras/setup_vscode_c_c++.sh'
alias setdevcl='~/dotfiles-dev/extras/setup_vscode_clangd.sh'
alias c='clear'
alias myip="curl ipinfo.io/ip"
alias sshp="sshpass -p welcome ssh "
alias vi='nvim'

# Git
##########
alias gcg="git config --edit --global"
alias gcl="git config --edit --local"
alias gs="git status -s \
 | fzf --no-sort --reverse \
 --preview 'git diff --color=always {+2} | diff-so-fancy' \
 --bind=ctrl-j:preview-down --bind=ctrl-k:preview-up \
 --preview-window=right:60%:wrap"

alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glogNoDays="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %C(bold blue)<%an>%Creset' --abbrev-commit"
alias epoc="date +%s"

# Tmux
# Attaches tmux to a session (example: ta portal)
alias ta='tmux attach -t'
# Creates a new session
alias tn='tmux new-session -s '
# Kill session
alias tk='tmux kill-session -t '
# Lists all ongoing sessions
alias tl='tmux list-sessions'
# Detach from session
alias td='tmux detach'
# Tmux Clear pane
alias tc='clear; tmux clear-history; clear'

# General
##########
alias whereami='npx @rafaelrinaldi/whereami -f json'
# alias l='exa --long --header --all --icons'
# alias ls='exa --header --sort=modified'
# alias tree='exa --tree --level=2'
alias lip="ip addr show en0"

## Function wrappers
# wrapper for easy extraction of compressed files
function extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.xz)    tar xvJf $1    ;;
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       unrar e $1     ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.apk)       unzip $1       ;;
          *.epub)      unzip $1       ;;
          *.xpi)       unzip $1       ;;
          *.zip)       unzip $1       ;;
          *.war)       unzip $1       ;;
          *.jar)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}

_fzf_complete_git() {
  _fzf_complete -- "$@" < <(
    git --help -a | grep -E '^\s+' | awk '{print $1}'
  )
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    tree)         find . -type d | fzf --preview 'tree -C {}' "$@";;
    *)            fzf "$@" ;;
  esac
}

function delete-branches() {
  git branch |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --multi --preview="git log {} --" |
    xargs --no-run-if-empty git branch --delete --force
}

function delete-remote-branches() {
  git branch -r |
    grep 'akgoyal' |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --multi --preview="git log {} --" |
    xargs --no-run-if-empty git branch --delete --force
}

function pr-checkout() {
  local jq_template pr_number

  jq_template='"'\
'#\(.number) - \(.title)'\
'\t'\
'Author: \(.user.login)\n'\
'Created: \(.created_at)\n'\
'Updated: \(.updated_at)\n\n'\
'\(.body)'\
'"'

  pr_number=$(
    gh api 'repos/:owner/:repo/pulls' |
    jq ".[] | $jq_template" |
    sed -e 's/"\(.*\)"/\1/' -e 's/\\t/\t/' |
    fzf \
      --with-nth=1 \
      --delimiter='\t' \
      --preview='echo -e {2}' \
      --preview-window=top:wrap |
    sed 's/^#\([0-9]\+\).*/\1/'
  )

  if [ -n "$pr_number" ]; then
    gh pr checkout "$pr_number"
  fi
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
