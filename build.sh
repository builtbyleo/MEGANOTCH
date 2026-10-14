#!/bin/zsh
# Builds a universal MegaNotch.app (and MegaNotch.zip for releases) into ./build
set -euo pipefail
cd "$(dirname "$0")"

ARCHS=(--arch arm64 --arch x86_64)
swift build -c release $ARCHS

APP=build/MegaNotch.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$(swift build -c release $ARCHS --show-bin-path)/MegaNotch" "$APP/Contents/MacOS/MegaNotch"
cp Info.plist "$APP/Contents/Info.plist"

# App icon, from Resources/AppIcon.png (regenerate it with: swift Scripts/make_icon.swift Resources/AppIcon.png)
ICONSET=build/AppIcon.iconset
rm -rf "$ICONSET"
mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
    sips -z $s $s Resources/AppIcon.png --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
    sips -z $((s * 2)) $((s * 2)) Resources/AppIcon.png --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf "$ICONSET"

# Ad-hoc signature only. A Developer ID needs a paid Apple Developer account.
codesign --force --sign - "$APP" >/dev/null

rm -f build/MegaNotch.zip
ditto -c -k --keepParent "$APP" build/MegaNotch.zip

echo "Built $APP and build/MegaNotch.zip"

# `open` would just re-activate an already-running old build, so restart it.
if pkill -x MegaNotch; then
    sleep 0.5
    open "$APP"
    echo "Restarted the running MegaNotch"
else
    echo "Run with: open $APP"
fi
