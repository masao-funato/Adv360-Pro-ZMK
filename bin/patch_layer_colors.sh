#!/usr/bin/env bash
# Make the Windows-mode layers (4 windows, 5 win_fn, 6 win_mod) show the same layer-LED colors
# as the Mac layers (0 base, 2 fn, 3 mod): off / blue / green. Layers 0-3 keep their colors.
#
# The layer-color table is hard-coded in ZMK (zmk/app/src/rgb_underglow.c, LAYER_COLORS),
# so this script patches the west checkout after `west update`. It restores the file first,
# so running it more than once gives the same result. It fails if the target line is missing.
set -euo pipefail
cd "$(dirname "$0")/.."

f="zmk/app/src/rgb_underglow.c"
git -C zmk checkout -- app/src/rgb_underglow.c

python3 - "$f" <<'PY'
import sys
path = sys.argv[1]
old = "    LED_RGB(0xFF0000), LED_RGB(0xFF00FF), LED_RGB(0x00FFFF), LED_RGB(0xFFFF00)};"
new = "    LED_RGB(0x000000), LED_RGB(0x0000FF), LED_RGB(0x00FF00), LED_RGB(0xFFFF00)};"
text = open(path, encoding="utf-8").read()
lines = text.split("\n")
found = sum(1 for line in lines if line == old)
if found != 1:
    sys.exit(f"patch_layer_colors: expected exactly 1 target line, found {found}")
lines = [new if line == old else line for line in lines]
open(path, "w", encoding="utf-8").write("\n".join(lines))
if sum(1 for line in lines if line == new) != 1:
    sys.exit("patch_layer_colors: verification failed after patching")
print("patch_layer_colors: layers 4-6 -> off/blue/green (layers 0-3 unchanged)")
PY

grep -n -A2 "LAYER_COLORS\[8\]" "$f"
