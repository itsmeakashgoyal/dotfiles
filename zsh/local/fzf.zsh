# ------------------------------------------------------------------------------
# Fzf Default Options
# ------------------------------------------------------------------------------

local fzf_default_opts=(
    '--preview-window right:50%:noborder:hidden'
    '--color "preview-bg:234"'
    '--bind "alt-p:toggle-preview"'
    '--color "prompt:green,header:grey,spinner:grey,info:grey,hl:blue,hl+:blue,pointer:red"'
)

# export FZF_DEFAULT_OPTS="${fzf_default_opts[*]}"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --strip-cwd-prefix'

# Define preview command with proper file type handling
export FZF_PREVIEW_COMMAND="([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {}) || ([[ -d {} ]] && tree -C {} || echo {} 2> /dev/null) || echo {} 2> /dev/null)"

# Set FZF default options
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi \
--preview '${FZF_PREVIEW_COMMAND}'"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Directory search command
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# ------------------------------------------------------------------------------
# Installer generated config completion, keybindings, etc.
# ------------------------------------------------------------------------------

# Add FZF to PATH if not already present
if [[ ! "$PATH" == *${HOME}/.config/.fzf/bin* ]]; then
    export PATH="${PATH:+${PATH}:}/${HOME}/.config/.fzf/bin"
fi

# Auto-completion
[[ $- == *i* ]] && source "${HOME}/.config/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
source "${HOME}/.config/.fzf/shell/key-bindings.zsh"

# Custom completion function
_fzf_comprun() {
	local command=$1
	shift

	case "$command" in
		tree)         find . -type d | fzf --preview 'tree -C {}' "$@";;
		*)            fzf "$@" ;;
	esac
}

# ------------------------------------------------------------------------------
# Custom Keybindings and Aliases
# ------------------------------------------------------------------------------

bindkey '^F' fzf-file-widget

# FZF, open selected file in nvim with preview!
alias of="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' | xargs nvim"

# ------------------------------------------------------------------------------
# Navigation Functions
# ------------------------------------------------------------------------------

cx() { cd "$@" && l; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

# ------------------------------------------------------------------------------
# File Search Functions
# ------------------------------------------------------------------------------

# Common function to search for a string in files using rga and fzf, and opens the file with nvim.
function _fif_common() {
    local ignore_case_flag="$1"
    shift

    local files
    local preview_cmd=$(printf "rga %s --pretty --context 10 '%s' {}" "$ignore_case_flag" "$*")
    local rga_output=$(rga --max-count=1 $ignore_case_flag --files-with-matches --no-messages "$*")

    # This is used to copy file names so that they can be used a project documentaiton
    echo "$rga_output" | xsel --clipboard --input
    IFS=$'\n' files=($(echo "$rga_output" | fzf-tmux +m --preview="$preview_cmd" --multi --select-1 --exit-0)) || return 1

    if [ ${#files[@]} -eq 0 ]; then
        echo "No files selected."
        return 0
    fi

    typeset -a temp_files
    for i in {1..${#files[@]}}; do
        if [[ -n "${files[i]}" ]]; then
        temp_files[i]=$(realpath "${files[i]}")
        fi
    done
    files=("${temp_files[@]}")
    local nvim_cmd=""
    case "${#files[@]}" in
        2)
        nvim -O "${files[1]}" "${files[2]}"
        ;;
        3)
        nvim_cmd="nvim -O \"${files[1]}\" -c 'wincmd j' -c \"vsplit ${files[2]}\" -c \"split ${files[3]}\""
        ;;
        4)
        nvim_cmd="nvim -O \"${files[1]}\" -c \"vsplit ${files[2]}\" -c \"split ${files[3]}\" -c 'wincmd h' -c \"split ${files[4]}\""
        ;;
        *)
        nvim_cmd="nvim \"${files[@]}\""
        ;;
    esac

    eval "$nvim_cmd"
}

# Wrapper function for case-sensitive search
function fifs() {
    _fif_common "" "$@"
}

# Wrapper function for case-insensitive search
function fif() {
    _fif_common "--ignore-case" "$@"
}