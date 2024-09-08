# ------------------------------------------------------------------------------
# Aliases and functions for Git
# ------------------------------------------------------------------------------

# Unalias oh-my-zsh aliases, in favour of my own custom config
unalias gco
unalias gbd
unalias gcmsg
unalias gcam
unalias gpr
unalias gp
unalias gstp

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
alias gc="git clean -f"
alias ghcurrentbranch='gh repo view --branch $(git rev-parse --abbrev-ref HEAD) --web'
alias ghc='~/dotfiles-dev/scripts/_gh_cli.sh'

# Git status with fugitive
# gs() {
#     if [ -n "$1" ]; then z $1; fi

#     if git rev-parse --git-dir > /dev/null 2>&1; then
#         $EDITOR '+Gedit :'
#     else
#         git status
#     fi
# }

# Git checkout with fzf fuzzy search
gco() {
    if [ -n "$1" ]; then git checkout $1; return; fi
    git branch -vv | fzf | awk '{print $1}' | xargs git checkout
}

# Git checkout remote branch with fzf fuzzy search
gcr() {
    git fetch
    if [ -n "$1" ]; then git checkout $1; return; fi
    git branch --all | fzf | sed "s#remotes/[^/]*/##" | xargs git checkout
}

# Git checkout history with fzf fuzzy search
gch() {
    local branches branch
    branches=$(git reflog show --pretty=format:'%gs ~ %gd' --date=relative | grep checkout | grep -oE '[^ ]+ ~ .*' | awk -F~ '!seen[$1]++' | head -n 11 | tail -n 10 | awk -F' ~ HEAD@{' '{printf("%s: %s\n", substr($2, 1, length($2)-1), $1)}')
    selection=$(echo "$branches" | fzf +m)
    branch=$(echo "$selection" | awk '{print $NF}')
    git checkout $branch
}

# Git checkout a PR with fzf fuzzy search
gpr() {
    if [ -n "$1" ]; then gh pr checkout $1; return; fi
    gh pr list | fzf | awk '{print $1}' | xargs gh pr checkout
}

# Git checkout tag with fzf fuzzy search
gct() {
    if [ -n "$1" ]; then git checkout $1; return; fi
    git tag | fzf | xargs git checkout
}

# Git delete branch with fzf fuzzy search
gbd() {
    if [ -n "$1" ]; then git branch -d $1; return; fi
    local selected=$(git branch -vv | fzf | awk '{print $1}' | sed "s/.* //")
    if [ -z "$selected" ]; then return; fi
    echo "Are you sure you would like to delete branch [\e[0;31m$selected\e[0m]? (Type 'delete' to confirm)"
    read confirmation
    if [[ "$confirmation" == "delete" ]]; then
        git branch -D $selected
    fi
}

# Commit with message
# Note: Oh-my-zsh has this alias already, but this function removes the need to wrap the message in quotes
gcmsg() {
    git commit -m "$*"
}

# Add all and commit with message
# Note: Oh-my-zsh has this alias already, but it doesn't add untracked files
gcam() {
    git add --all && git commit -m "$*"
}

# Add all and stash with message
gstam() {
    git add --all && git stash push -m "$*"
}

# Add all and backup to stash with message
gstab() {
    git add --all && git stash push -m "$*" && git stash apply
}

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

_fzf_complete_git() {
	_fzf_complete -- "$@" < <(
		git --help -a | grep -E '^\s+' | awk '{print $1}'
	)
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


# Use Git’s colored diff when available
hash git &>/dev/null;
if [ $? -eq 0 ]; then
	function diff() {
		git diff --no-index --color-words "$@";
	}
fi;

function logg() {
    git lg | fzf --ansi --no-sort \
        --preview 'echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % git show % --color=always' \
        --preview-window=right:50%:wrap --height 100% \
        --bind 'enter:execute(echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % sh -c "git show % | nvim -c \"setlocal buftype=nofile bufhidden=wipe noswapfile nowrap\" -c \"nnoremap <buffer> q :q!<CR>\" -")' \
        --bind 'ctrl-e:execute(echo {} | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % sh -c "gh browse %")' \
}

# Add all changes to git, commit with given message, and push
function gac() {
    git add .
    git commit -m "$1"
    git push
}

# Add all changes to git, commit with given message and signed-off-by line, and push
function gacs() {
    git add .
    git commit -m "$1" -s
    git push
}

# Find a repo for authenticated user with gh CLI and cd into it, clone and cd if not found on disk
function repo() {
    export repo=$(fd . ${HOME}/dev --type=directory --max-depth=1 --color always| awk -F "/" '{print $5}' | fzf --ansi --preview 'onefetch /home/decoder/dev/{1}' --preview-window up)
    if [[ -z "$repo" ]]; then
        echo "Repository not found"
    else
        echo "Repository found locally, entering"
        cd ${HOME}/dev/$repo
        if [[ -d .git ]]; then
            echo "Fetching origin"
            git fetch origin
            onefetch
        fi
            create_tmux_session "${HOME}/dev/$repo"
    fi
}


function open_file_git_staged() {
    ~/dotfiles-dev/scripts/_open-file-git-staged.sh 
}

# Binds Ctrl+Alt+O to open_file_git
bindkey "^[^O" open_file_git_staged
zle -N open_file_git_staged


function f_git_enter() {
    BUFFER="~/dotfiles-dev/scripts/_open-file-git.sh"
    zle accept-line
}

zle -N f_git_enter
bindkey '^o' f_git_enter
