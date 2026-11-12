#!/bin/bash
# Compiles the sources and wraps the binary into build/Morgenseiten.app.
# Calls swiftc directly, so the Command Line Tools are enough; neither Xcode
# nor the Swift Package Manager is required.
set -euo pipefail

cd "$(dirname "$0")/.."

APP="build/Morgenseiten.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"

swiftc -O -swift-version 6 -parse-as-library \
    -target "$(uname -m)-apple-macosx14.0" \
    Sources/Morgenseiten/*.swift \
    -o "$APP/Contents/MacOS/Morgenseiten"

cp Resources/Info.plist "$APP/Contents/Info.plist"

# Ad-hoc signature so macOS runs the bundle locally.
codesign --force --sign - "$APP"

echo "Built $APP"
