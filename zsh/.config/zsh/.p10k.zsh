#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/.p10k.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Powerlevel10k, styled like the previous starship prompt (Gruvbox):
#
#   ~/dotfiles (a1b2c3d) on  master ⇡1 +2 !3 ?4 took 3s           venv
#   ❯
#
# Why p10k: it renders in-process and gets git status asynchronously from
# gitstatusd, so the prompt costs ~6ms per Enter vs ~61ms for starship
# (zsh-bench, `dutils bench --real`), and can afford full git status in large
# repos. Hand-written (not `p10k configure` output) so it stays readable; every
# parameter is documented in `p10k help` / the powerlevel10k README.
#
# Colours follow `dutils theme` ($DOTFILES_THEME from 01-exports.zsh, which runs
# before this file). Switch back to starship: DOTFILES_PROMPT=starship (.zshrc).

# Temporarily change options (p10k's standard config preamble).
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # ── Gruvbox palette (bright accents on dark, faded accents on light) ─────────
  if [[ ${DOTFILES_THEME:-dark} == light ]]; then
    local aqua='#427b58' purple='#8f3f71' yellow='#b57614' green='#79740e' \
          red='#9d0006' orange='#af3a03' blue='#076678' gray='#7c6f64' dim='#98971a'
  else
    local aqua='#8ec07c' purple='#d3869b' yellow='#fabd2f' green='#b8bb26' \
          red='#fb4934' orange='#fe8019' blue='#83a598' gray='#a89984' dim='#98971a'
  fi
  local italic=$'%{\e[3m%}' noitalic=$'%{\e[23m%}'

  # ── Layout ──────────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                     # ~/path, full (no truncation), bold italic aqua
    vcs                     # (hash) on  branch + async git status
    command_execution_time  # took 3s (only when >= 2s)
    newline
    prompt_char             # ❯ green / red on error, ❮ in vi normal mode
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    anaconda                # active conda env (base hidden)
    virtualenv              # active venv (uv / python -m venv)
  )

  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=none
  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=true
  typeset -g POWERLEVEL9K_BACKGROUND=                            # transparent
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=  # no padding
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=           # no icons unless set below
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true                # blank line between prompts
  typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_{FIRST,NEWLINE,LAST}_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_SHOW_RULER=false
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '

  # ── dir ─────────────────────────────────────────────────────────────────────
  # The full path from ~ built from $PWD, like starship (truncation_length = 0).
  # Not p10k's own text: that abbreviates with zsh named directories, so the
  # `hash -d` bookmarks in 17-bookmarks.zsh turned ~/dotfiles into "~df".
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$aqua
  typeset -g POWERLEVEL9K_DIR_CONTENT_EXPANSION="%B${italic}"'${${PWD/#$HOME/~}//\%/%%}'"${noitalic}%b"
  typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_COLOR=$aqua
  typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_VISUAL_IDENTIFIER_EXPANSION=''
  # Icon in front of well-known folders (the path itself is always shown).
  typeset -g POWERLEVEL9K_DIR_CLASSES=(
    '~/Documents(|/*)'   DOCUMENTS  ''
    '~/Downloads(|/*)'   DOWNLOADS  ''
    '~/Music(|/*)'       MUSIC      ''
    '~/Pictures(|/*)'    PICTURES   ''
    '~/Developer(|/*)'   DEVELOPER  ''
    '*'                  DEFAULT    ''
  )
  typeset -g POWERLEVEL9K_DIR_DOCUMENTS_VISUAL_IDENTIFIER_EXPANSION='󰈙'
  typeset -g POWERLEVEL9K_DIR_DOWNLOADS_VISUAL_IDENTIFIER_EXPANSION='󰇚'
  typeset -g POWERLEVEL9K_DIR_MUSIC_VISUAL_IDENTIFIER_EXPANSION='󰝚'
  typeset -g POWERLEVEL9K_DIR_PICTURES_VISUAL_IDENTIFIER_EXPANSION='󰋩'
  typeset -g POWERLEVEL9K_DIR_DEVELOPER_VISUAL_IDENTIFIER_EXPANSION='󰲋'

  # ── vcs: "(a1b2c3d) on  branch ⇡1 ⇣2 *1 ~1 +2 !3 ?4" ──────────────────────
  # Rendered by gitstatusd in the background, so it's cheap even in huge repos.
  # Before the first result arrives the segment is drawn in gray (loading).
  function my_git_formatter() {
    emulate -L zsh
    if [[ -n $P9K_CONTENT ]]; then
      # Placeholder text while gitstatusd hasn't answered for this directory
      # yet: show nothing rather than the word "loading".
      typeset -g my_git_format=${P9K_CONTENT:#$POWERLEVEL9K_VCS_LOADING_TEXT}
      return
    fi
    if (( $1 )); then
      local hash="%F{$_my_gray}" branch="%B%F{$_my_purple}" ahead="%F{$_my_aqua}" \
            behind="%F{$_my_orange}" staged="%F{$_my_green}" unstaged="%F{$_my_yellow}" \
            untracked="%F{$_my_blue}" conflicted="%F{$_my_red}"
    else
      local hash="%F{$_my_gray}" branch=$hash ahead=$hash behind=$hash staged=$hash \
            unstaged=$hash untracked=$hash conflicted=$hash
    fi
    local res="${hash}(${VCS_STATUS_COMMIT[1,7]})%f "
    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local b=${(V)VCS_STATUS_LOCAL_BRANCH}
      (( $#b > 40 )) && b[18,-18]="…"
      res+="on ${branch} ${b//\%/%%}%b%f"
    elif [[ -n $VCS_STATUS_TAG ]]; then
      res+="at ${branch}#${(V)VCS_STATUS_TAG//\%/%%}%b%f"
    else
      res+="${hash}(detached)%f"
    fi
    (( VCS_STATUS_COMMITS_AHEAD  )) && res+=" ${ahead}⇡${VCS_STATUS_COMMITS_AHEAD}"
    (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${behind}⇣${VCS_STATUS_COMMITS_BEHIND}"
    (( VCS_STATUS_STASHES        )) && res+=" ${hash}*${VCS_STATUS_STASHES}"
    [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
    (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    (( VCS_STATUS_NUM_STAGED     )) && res+=" ${staged}+${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${unstaged}!${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}?${VCS_STATUS_NUM_UNTRACKED}"
    (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${unstaged}─"  # too big to scan fully
    typeset -g my_git_format="$res%f"
  }
  functions -M my_git_formatter 2>/dev/null
  typeset -g _my_gray=$gray _my_purple=$purple _my_aqua=$aqua _my_orange=$orange \
             _my_green=$green _my_yellow=$yellow _my_blue=$blue _my_red=$red
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_LOADING_TEXT=loading
  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=

  # ── command_execution_time: "took 3s" ───────────────────────────────────────
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$yellow
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX='%ftook '
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_CONTENT_EXPANSION="${italic}"'${P9K_CONTENT}'"${noitalic}"

  # ── prompt_char: ❯ / ❮ (vi normal) / V (visual) / ▶ (overwrite) ────────────
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VIVIS,VIOWR}_FOREGROUND=$green
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_FOREGROUND=$yellow
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$red
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='%B❯%b'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='%B❮%b'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='%BV%b'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='%B▶%b'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=

  # ── Python envs (right side) ────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$dim
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=
  typeset -g POWERLEVEL9K_VIRTUALENV_VISUAL_IDENTIFIER_EXPANSION=''
  typeset -g POWERLEVEL9K_ANACONDA_FOREGROUND=$dim
  typeset -g POWERLEVEL9K_ANACONDA_VISUAL_IDENTIFIER_EXPANSION=
  # Hide the always-on "base" env, like starship's ignore_base.
  typeset -g POWERLEVEL9K_ANACONDA_CONTENT_EXPANSION='${${CONDA_DEFAULT_ENV:#base}:+ conda:${CONDA_DEFAULT_ENV}}'

  # ── Behaviour ───────────────────────────────────────────────────────────────
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
  # Instant prompt: draws the prompt before the rest of .zshrc finishes loading.
  # quiet = no warnings; .zshrc prints the startup logo BEFORE instant prompt.
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
