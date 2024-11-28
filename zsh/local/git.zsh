#!/usr/bin/env zsh
#                     █████
#                    ░░███
#   █████████  █████  ░███████
#  ░█░░░░███  ███░░   ░███░░███
#  ░   ███░  ░░█████  ░███ ░███
#    ███░   █ ░░░░███ ░███ ░███
#   █████████ ██████  ████ █████
#  ░░░░░░░░░ ░░░░░░  ░░░░ ░░░░░
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/local/git.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
#█▓▒░
# ------------------------------------------------------------------------------
# Git Configuration: Aliases and Functions
# ------------------------------------------------------------------------------

# Unalias conflicting oh-my-zsh git aliases
unalias gco gcmsg gcam gpr gp gstp gbd 2>/dev/null

# ------------------------------------------------------------------------------
# Basic Git Aliases
# ------------------------------------------------------------------------------
alias gs="git status"                  # Git status
alias gc="git clean -f"                # Force clean untracked files
alias gcg="git config --edit --global" # Edit global Git config
alias gcl="git config --edit --local"  # Edit local Git config

# ------------------------------------------------------------------------------
# Git Log Aliases
# ------------------------------------------------------------------------------
# Pretty git log with graph
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias glogn="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %C(bold blue)<%an>%Creset' --abbrev-commit"

# ------------------------------------------------------------------------------
# GitHub CLI Aliases
# ------------------------------------------------------------------------------
alias ghcb='gh repo view --branch $(git rev-parse --abbrev-ref HEAD) --web' # Open current branch on GitHub

# ------------------------------------------------------------------------------
# Branch Management Functions
# ------------------------------------------------------------------------------
# Fuzzy checkout local branch
gco() {
    if [ -n "$1" ]; then
        git checkout "$1"
        return
    fi
    git branch -vv | fzf | awk '{print $1}' | xargs git checkout
}

# Fuzzy checkout remote branch
gcr() {
    git fetch
    if [ -n "$1" ]; then
        git checkout "$1"
        return
    fi
    git branch --all | fzf | sed "s#remotes/[^/]*/##" | xargs git checkout
}

# Fuzzy checkout from branch history
gch() {
    local branches selection branch
    branches=$(git reflog show --pretty=format:'%gs ~ %gd' --date=relative |
        grep 'checkout' |
        grep -oE '[^ ]+ ~ .*' |
        awk -F~ '!seen[$1]++' |
        head -n 10 |
        awk -F' ~ HEAD@{' '{printf("%s: %s\n", substr($2, 1, length($2)-1), $1)}')
    selection=$(echo "$branches" | fzf +m)
    branch=$(echo "$selection" | awk '{print $NF}')
    [ -n "$branch" ] && git checkout "$branch"
}

# Fuzzy checkout PR
gpr() {
    if [ -n "$1" ]; then
        gh pr checkout "$1"
        return
    fi
    gh pr list | fzf | awk '{print $1}' | xargs gh pr checkout
}

# Fuzzy checkout tag
gct() {
    if [ -n "$1" ]; then
        git checkout "$1"
        return
    fi
    git tag | fzf | xargs git checkout
}

# Fuzzy delete branch with confirmation
gbd() {
    if [ -n "$1" ]; then
        git branch -d "$1"
        return
    fi
    local selected=$(git branch -vv | fzf | awk '{print $1}')
    if [ -n "$selected" ]; then
        echo "Delete branch [\e[0;31m$selected\e[0m]? (Type 'delete' to confirm)"
        read -r confirmation
        [[ "$confirmation" == "delete" ]] && git branch -D "$selected"
    fi
}

# ------------------------------------------------------------------------------
# Commit Functions
# ------------------------------------------------------------------------------
# Commit with message
gcmsg() {
    git commit -m "$*"
}

# Add all and commit
gcam() {
    git add --all && git commit -m "$*"
}

# Add all, commit, and push
gac() {
    git add . && git commit -m "$1" && git push
}

# Add all, commit with sign-off, and push
gacs() {
    git add . && git commit -s -m "$1" && git push
}

# ------------------------------------------------------------------------------
# Stash Functions
# ------------------------------------------------------------------------------
# Add all and stash with message
gstam() {
    git add --all && git stash push -m "$*"
}

# Add all and backup to stash
gstab() {
    git add --all && git stash push -m "$*" && git stash apply
}

# ------------------------------------------------------------------------------
# Undo/Reset Functions
# ------------------------------------------------------------------------------
# Undo last commit and tip of branch
# Optionally pass param to specify number of commits to undo (ie. `gundo 3`)
gundo() {
    if [ -n "$1" ]; then
        git reset HEAD~$1
    else
        git reset HEAD~1
    fi
    echo "\nRecent commits:"
    glog -n 5
}

# Discard all unstaged changes & untracked files to trash bin
# Note: This requires `trash` util so that the files can be restored if needed later
nah() {
    echo "Are you sure you would like to discard/delete all unstaged changes & untracked files? (Type 'y' to confirm)"
    read confirmation
    if [[ "$confirmation" == "y" ]]; then
        git ls-files --modified --other --exclude-standard | xargs trash -rf
        git reset --hard
        git clean -qf
    fi
}

# ------------------------------------------------------------------------------
# Interactive Functions
# ------------------------------------------------------------------------------
# Interactive git log viewer
logg() {
    git lg | fzf --ansi --no-sort \
        --preview 'echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % git show % --color=always' \
        --preview-window=right:50%:wrap \
        --bind 'enter:execute(echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % sh -c "git show % | nvim -")' \
        --bind 'ctrl-e:execute(echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % sh -c "gh browse %")'
}

# FZF completion for git commands
_fzf_complete_git() {
    _fzf_complete -- "$@" < <(
        git --help -a | grep -E '^\s+' | awk '{print $1}'
    )
}

# ------------------------------------------------------------------------------
# Advanced Git Functions
# ------------------------------------------------------------------------------

# Interactive branch deletion with preview
delete-branches() {
    echo "Selecting branches to delete (use TAB for multi-select)..."
    git branch |
        grep --invert-match '\*' |
        cut -c 3- |
        fzf --multi \
            --preview="git log {} --" \
            --preview-window=right:60% \
            --bind='ctrl-/:toggle-preview' |
        xargs --no-run-if-empty git branch --delete --force
}

# Interactive remote branch deletion
delete-remote-branches() {
    echo "Selecting remote branches to delete (use TAB for multi-select)..."
    local remote=${1:-origin} # Default to 'origin' if no remote specified
    git branch -r |
        grep "$remote/" |
        grep --invert-match '\*' |
        cut -c 3- |
        fzf --multi \
            --preview="git log {} --" \
            --preview-window=right:60% \
            --bind='ctrl-/:toggle-preview' |
        xargs --no-run-if-empty git push "$remote" --delete
}

# Enhanced PR checkout with preview
pr-checkout() {
    local jq_template pr_number

    # Template for PR information display
    jq_template='"' \
        '#\(.number) - \(.title)' \
        '\t' \
        'Author: \(.user.login)\n' \
        'Created: \(.created_at)\n' \
        'Updated: \(.updated_at)\n\n' \
        '\(.body)' \
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

# Enhanced diff function using Git's colored output
if hash git &>/dev/null; then
    diff() {
        git diff --no-index --color-words "$@"
    }
fi

# Repository management with FZF and tmux integration
repo() {
    local dev_path="${HOME}/dev"
    local selected_repo

    # Find and select repository
    selected_repo=$(fd . "$dev_path" \
        --type=directory \
        --max-depth=1 \
        --color always |
        fzf --ansi \
            --preview "onefetch ${dev_path}/{1}" \
            --preview-window up)

    if [[ -z "$selected_repo" ]]; then
        echo "No repository selected"
        return 1
    fi

    echo "Repository found locally, entering"
    cd "$selected_repo" || return 1

    # Update repository if it's a git repo
    if [[ -d .git ]]; then
        echo "Fetching origin"
        git fetch origin
        onefetch
    fi

    # Create tmux session if function exists
    if type create_tmux_session >/dev/null 2>&1; then
        create_tmux_session "$selected_repo"
    fi
}
