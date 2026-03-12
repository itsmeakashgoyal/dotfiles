#!/usr/bin/env zsh
# Profile zsh startup time
# Usage: zsh ./scripts/utils/profile_zsh.sh

ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"

echo "═══════════════════════════════════════════"
echo "  ZSH Startup Performance Profile"
echo "═══════════════════════════════════════════"
echo ""

# Enable profiling
cat > /tmp/profile_zshrc.zsh <<'EOF'
zmodload zsh/zprof
source "${ZDOTDIR:-$HOME/.config/zsh}/.zshrc"
zprof
EOF

echo "Running profiled startup..."
echo ""
ZDOTDIR="$ZDOTDIR" zsh -c 'source /tmp/profile_zshrc.zsh' 2>&1 | tail -50

rm -f /tmp/profile_zshrc.zsh
