#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ powershell/Documents/PowerShell/profile.d/50-git.ps1
# ░▓▓▓▓▓▓▓▓▓▓
#
# Git shortcuts + television-driven interactive pickers, mirroring the fuzzy
# functions in zsh/.config/zsh/conf.d/06-git.zsh (ported from fzf to tv there
# too — see 09-television.zsh).

function g     { git @args }
function gs    { git status -sb }
function ga    { git add @args }
function gaa   { git add -A }
function gc    { git commit -m @args }
function gca   { git commit --amend --no-edit }
function gp    { git push @args }
function gpl   { git pull --rebase }
function gf    { git fetch --all --prune }
function gb    { git branch @args }
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

# Extracts a branch name from a `git branch`/`git branch -vv` line, current
# branch or not (`git branch -vv`'s leading "* " on the checked-out branch
# is a separate whitespace-delimited token — a plain first-word split, as
# 06-git.zsh's `awk '{print $1}'` does, would return "*" instead of the name
# on that one line).
function script:_gitBranchFromLine {
    param([string]$Line)
    if ($Line -match '^\*?\s*(\S+)') { $Matches[1] } else { $null }
}

# Fuzzy checkout local branch (plain checkout if a name is given)
function gco {
    param([Parameter(ValueFromRemainingArguments)][string[]]$Args)
    if ($Args) { git checkout @Args; return }
    if (-not (_cmd tv)) { Write-Warning 'television (tv) not found for interactive selection'; return }
    $selected = git branch -vv | tv
    if (-not $selected) { return }
    $branch = script:_gitBranchFromLine $selected
    if ($branch) { git checkout $branch }
}

# Fuzzy checkout remote branch (fetches first)
function gcr {
    param([string]$Branch)
    if (-not (_cmd tv)) { Write-Warning 'television (tv) not found for interactive selection'; return }
    git fetch
    if ($Branch) { git checkout $Branch; return }
    $selected = git branch --all | tv
    if (-not $selected) { return }
    $branch = (script:_gitBranchFromLine $selected) -replace '^remotes/[^/]+/', ''
    if ($branch) { git checkout $branch }
}

# Fuzzy checkout PR (requires GitHub CLI)
function gpr {
    param([string]$Number)
    if (-not (_cmd gh)) { Write-Warning 'gh (GitHub CLI) not found'; return }
    if ($Number) { gh pr checkout $Number; return }
    if (-not (_cmd tv)) { Write-Warning 'television (tv) not found for interactive selection'; return }
    $selected = gh pr list | tv
    if (-not $selected) { return }
    $prNumber = ($selected -split '\s+')[0]
    if ($prNumber) { gh pr checkout $prNumber }
}

# Fuzzy checkout tag
function gct {
    param([string]$Tag)
    if ($Tag) { git checkout $Tag; return }
    if (-not (_cmd tv)) { Write-Warning 'television (tv) not found for interactive selection'; return }
    $selected = git tag | tv
    if ($selected) { git checkout $selected.Trim() }
}

# Fuzzy delete branch with confirmation (plain delete if a name is given)
function gbd {
    param([Parameter(ValueFromRemainingArguments)][string[]]$Args)
    if ($Args) { git branch -d @Args; return }
    if (-not (_cmd tv)) { Write-Warning 'television (tv) not found for interactive selection'; return }
    $selected = git branch -vv | tv
    if (-not $selected) { return }
    $branch = script:_gitBranchFromLine $selected
    if (-not $branch) { return }
    Write-Host "Delete branch [$branch]? (Type 'delete' to confirm)" -ForegroundColor Yellow
    if ((Read-Host) -eq 'delete') { git branch -D $branch }
}

# Interactive git log viewer — opens the selected commit's diff in a
# read-only nvim buffer (matches zsh's logg(): `git show $hash | nvim -`).
function logg {
    if (-not (_cmd tv)) { glog; return }
    $selected = git log --oneline --graph --decorate --color=always | tv --ansi
    if (-not $selected) { return }
    if ($selected -match '[a-f0-9]{7,40}') {
        git show $Matches[0] | nvim -
    }
}
