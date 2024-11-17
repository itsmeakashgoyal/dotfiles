# ------------------------------------------------------------------------------
# Antidote Plugin Manager Configuration
# ------------------------------------------------------------------------------

# Define plugin files
zsh_plugins="${ZDOTDIR}/.zsh_plugins"
zsh_plugins_txt="${zsh_plugins}.txt"
zsh_plugins_compiled="${ZDOTDIR}/zsh_plugins.zsh"

# Ensure required directories and files exist
[[ ! -f "$zsh_plugins_txt" ]] && touch "$zsh_plugins_txt"
[[ ! -d "$ANTIDOTE_DIR" ]] && {
    echo "Error: ANTIDOTE_DIR not found: $ANTIDOTE_DIR"
    return 1
}

# Initialize antidote
fpath=("${ANTIDOTE_DIR}/functions" $fpath)
autoload -Uz antidote
source "${ANTIDOTE_DIR}/antidote.zsh"

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
# Compile bundles and restart shell
compile_antidote() {
    if [[ -x "${ZDOTDIR}/bundle_compile" ]]; then
        "${ZDOTDIR}/bundle_compile" &&
            echo "✅ Bundles compiled successfully" &&
            exec zsh
    else
        echo "❌ Error: bundle_compile script not found or not executable"
        return 1
    fi
}

# Update antidote bundles
update_antidote() {
    if [[ -f "$zsh_plugins_txt" ]]; then
        antidote bundle <"$zsh_plugins_txt" >|"$zsh_plugins_compiled" &&
            echo "✅ Antidote bundles updated successfully"
    else
        echo "❌ Error: Plugin source file not found"
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Load Plugins
# ------------------------------------------------------------------------------
# Source compiled plugins if they exist
[[ -f "$zsh_plugins_compiled" ]] && source "$zsh_plugins_compiled"
