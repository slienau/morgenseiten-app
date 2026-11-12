#!/bin/bash
# Regenerates Resources/AppIcon.icns from scripts/draw-icon.swift.
# Only needed after changing the icon drawing; the .icns is checked in.
set -euo pipefail

cd "$(dirname "$0")/.."

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

swiftc -O -parse-as-library scripts/draw-icon.swift -o "$WORK/draw-icon"
"$WORK/draw-icon" "$WORK/icon-1024.png"

SET="$WORK/AppIcon.iconset"
mkdir "$SET"
for size in 16 32 128 256 512; do
    sips -z "$size" "$size" "$WORK/icon-1024.png" --out "$SET/icon_${size}x${size}.png" >/dev/null
    double=$((size * 2))
    sips -z "$double" "$double" "$WORK/icon-1024.png" --out "$SET/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil --convert icns "$SET" --output Resources/AppIcon.icns

echo "Wrote Resources/AppIcon.icns"
