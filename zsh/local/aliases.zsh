# ------------------------------------------------------------------------------
# General Aliases
# ------------------------------------------------------------------------------

# File and Directory Listing
alias tree='tree -a -I .git'
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ld='eza -lD'                                        # lists only directories (no files)
alias lf='eza -lF --color=always | grep -v /'             # lists only files (no directories)
alias lh='eza -dl .* --group-directories-first'           # lists only hidden files (no directories)
alias ll='eza -al --group-directories-first'              # lists everything with directories first
alias ls='eza -lF --color=always --sort=size | grep -v /' # lists only files sorted by size

# System and Navigation
alias c='clear'
alias sshp="sshpass -p welcome ssh "
alias vi='nvim'
alias reload="exec ${SHELL} -l"     # Reload the shell (i.e. invoke as a login shell)
alias path='echo -e ${PATH//:/\\n}' # Print each PATH entry on a separate line

# Global Aliases (can be used anywhere in the command line)
alias -g H=' --help'
alias -g L='| less'
alias -g R="2>&1 | tee output.txt"
alias -g T="| tail -n +2"
alias -g V=' --version'
alias -g W='| nvim -c "setlocal buftype=nofile bufhidden=wipe" -c "nnoremap <buffer> q :q!<CR>" -'

# List out all globally installed npm packages
alias list-npm-globals='npm list -g --depth=0'

# Searches for text in all files in the current folder
ftext() {
    # -i case-insensitive
    # -I ignore binary files
    # -H causes filename to be printed
    # -r recursive search
    # -n causes line number to be printed
    # optional: -F treat search term as a literal, not a regular expression
    # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
    grep -iIHrn --color=always "$1" . | less -r
}

# Copy file with a progress bar
cpp() {
    set -e
    strace -q -ewrite cp -- "${1}" "${2}" 2>&1 |
        awk '{
        count += $NF
        if (count % 10 == 0) {
            percent = count / total_size * 100
            printf "%3d%% [", percent
            for (i=0;i<=percent;i++)
                printf "="
            printf ">"
            for (i=percent;i<100;i++)
                printf " "
            printf "]\r"
        }
    }
    END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# Goes up a specified number of directories  (i.e. up 4)
up() {
    local d=""
    limit=$1
    for ((i = 1; i <= limit; i++)); do
        d=$d/..
    done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then
        d=..
    fi
    cd $d
}

# Trim leading and trailing spaces (for scripts)
trim() {
    local var=$*
    var="${var#"${var%%[![:space:]]*}"}" # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}" # remove trailing whitespace characters
    echo -n "$var"
}

# upgrade fzf
update-fzf() {
    echo "Updating fzf..."
    if [ -d ~/.config/.fzf ]; then
        (cd ~/.config/.fzf &&
            git pull &&
            ./install --all &&
            echo "fzf updated successfully!") ||
            echo "Failed to update fzf"
    else
        echo "fzf directory not found at ~/.config/.fzf"
    fi
}
