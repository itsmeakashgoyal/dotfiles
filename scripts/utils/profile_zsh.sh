#!/usr/bin/env zsh
# Profile zsh startup time
# Usage: zsh ./scripts/utils/profile_zsh.sh

ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"

echo "═══════════════════════════════════════════"
echo "  ZSH Startup Performance Profile"
echo "═══════════════════════════════════════════"
echo ""

# Enable profiling
profile_script=$(mktemp -t profile_zshrc.XXXXXX.zsh)
cat > "$profile_script" <<'EOF'
zmodload zsh/zprof
source "${ZDOTDIR:-$HOME/.config/zsh}/.zshrc"
zprof
EOF

echo "Running profiled startup..."
echo ""
ZDOTDIR="$ZDOTDIR" zsh -c "source $profile_script" 2>&1 | tail -50

rm -f "$profile_script"
