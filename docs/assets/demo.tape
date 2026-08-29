#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ docs/assets/demo.tape
# ░▓▓▓▓▓▓▓▓▓▓
#
# VHS script that records docs/assets/demo.gif, embedded in README.md.
# Regenerate with (from the repo root):
#   vhs docs/assets/demo.tape
#   ffmpeg -y -i docs/assets/demo.gif -vf \
#     "fps=15,scale=1000:-1:flags=lanczos,split[s0][s1];[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=bayer" \
#     docs/assets/demo.gif
# (the ffmpeg pass halves the file size via a shared color palette + lower fps/width)

Output docs/assets/demo.gif

Set Shell "zsh"
Set FontFamily "FiraCode Nerd Font Mono"
Set FontSize 18
Set Width 1200
Set Height 750
Set Theme "Catppuccin Mocha"
Set Padding 20
Set TypingSpeed 60ms

Sleep 800ms
Type "exec zsh"
Enter
Sleep 3000ms

Type "ll"
Sleep 400ms
Enter
Sleep 2200ms

Type "lt"
Sleep 400ms
Enter
Sleep 2200ms

Type "dutils help"
Sleep 400ms
Enter
Sleep 3000ms

Type "nvim README.md"
Sleep 400ms
Enter
Sleep 2200ms
Escape
Type ":q"
Enter
Sleep 500ms

Type "exit"
Enter
