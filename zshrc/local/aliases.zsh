# ------------------------------------------------------------------------------
# General Aliases
# ------------------------------------------------------------------------------

alias tree='tree -a -I .git'

# Eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ld='eza -lD'      # lists only directories (no files)
alias lf='eza -lF --color=always | grep -v /'       # lists only files (no directories)
alias lh='eza -dl .* --group-directories-first'     # lists only hidden files (no directories)
alias ll='eza -al --group-directories-first'        # lists everything with directories first
alias ls='eza -lF --color=always --sort=size | grep -v /'      # lists only files sorted by size

alias c='clear'
alias sshp="sshpass -p welcome ssh "
alias vi='nvim'
alias z='zellij'

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

alias -g H=' --help'
alias -g L='| less'
alias -g R="2>&1 | tee output.txt"
alias -g T="| tail -n +2"
alias -g V=' --version'
alias -g W='| nvim -c "setlocal buftype=nofile bufhidden=wipe" -c "nnoremap <buffer> q :q!<CR>" -'

# List out all globally installed npm packages
alias list-npm-globals='npm list -g --depth=0'