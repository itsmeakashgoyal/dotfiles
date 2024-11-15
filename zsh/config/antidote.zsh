# ------------------------------------------------------------------
## Antidote plugin manager setup
# ------------------------------------------------------------------

# Set the root name of the plugins files (.txt and .zsh) antidote will use.
zsh_plugins="${ZDOTDIR}/.zsh_plugins"

# Ensure the .zsh_plugins.txt file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath=(${ANTIDOTE_DIR}/functions $fpath)
autoload -Uz antidote
source ${ANTIDOTE_DIR}/antidote.zsh

# Helper function to compile bundles and source zshrc
function compile_antidote() {
    sh ${ZDOTDIR}/bundle_compile
    exec zsh
    echo 'Sourced zshrc'
}

alias update_antidote='antidote bundle < ${ZDOTDIR}/.zsh_plugins.txt >| ${ZDOTDIR}/zsh_plugins.zsh'

# Source compiled antidote bundles and configs
[ -f ${ZDOTDIR}/zsh_plugins.zsh ] && source ${ZDOTDIR}/zsh_plugins.zsh