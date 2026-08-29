#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ docs/assets/demo.tape
# ░▓▓▓▓▓▓▓▓▓▓
#
# VHS script that records docs/assets/demo.gif, embedded in README.md.
# Regenerate with: vhs docs/assets/demo.tape (run from the repo root).
#
# Don't re-encode the output afterward (e.g. via ffmpeg palettegen with a
# lower fps/width and dithering) to shave file size - it visibly degrades
# text sharpness on this kind of flat-color terminal content for little
# actual size win, since VHS's own ffmpeg-based GIF encoder is already
# well-optimized. Ship VHS's raw output as-is.

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
