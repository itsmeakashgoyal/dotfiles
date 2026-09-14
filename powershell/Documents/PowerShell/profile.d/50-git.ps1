#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/profile.d/50-git.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# Git shortcuts (mirrors the zsh 06-git.zsh aliases) + an fzf-driven log.

function g     { git @args }
function gs    { git status -sb }
function ga    { git add @args }
function gaa   { git add -A }
function gc    { git commit -m @args }
function gca   { git commit --amend --no-edit }
function gp    { git push @args }
function gpl   { git pull --rebase }
function gf    { git fetch --all --prune }
function gco   { git checkout @args }
function gb    { git branch @args }
function gbd   { git branch -d @args }
function gd    { git diff @args }
function gds   { git diff --staged }
function glog  { git log --oneline --graph --decorate --all }
function gst   { git stash @args }
function gstp  { git stash pop }
function grb   { git rebase @args }
function gri   { git rebase -i @args }
function gcp   { git cherry-pick @args }
function grh   { git reset --hard @args }
function grs   { git restore @args }

# Interactive git log with fzf preview
function glf {
    if (-not (_cmd fzf)) { glog; return }
    git log --oneline --color=always |
        fzf --ansi --no-sort --reverse --tiebreak=index `
            --preview 'git show --color=always {1}' `
            --preview-window 'right:60%' `
            --bind 'enter:execute(git show --color=always {1} | bat --paging=always)'
}
