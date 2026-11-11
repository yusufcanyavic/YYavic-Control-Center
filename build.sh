#!/bin/zsh
# YYavic Control Center - builds the menu bar app and the command line tools.
# Copyright (C) 2026 Yusufcan Yavic
# SPDX-License-Identifier: GPL-3.0-or-later
#
#   zsh build.sh            -> build/YYavic Control Center.app, build/yycc-kb, build/ite8291-probe
#
# Needs Xcode (or the Command Line Tools with Swift). Set DEVELOPER_DIR to pick
# a specific Xcode. The app is ad-hoc signed (not notarized).
set -e
cd "$(dirname "$0")"
VERSION=${VERSION:-1.0.0}
ARCH=${ARCH:-$(uname -m)}
APP="build/YYavic Control Center.app"
rm -rf build; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc -O -swift-version 5 -parse-as-library -target $ARCH-apple-macos13.0 app/*.swift -o "$APP/Contents/MacOS/YYavicControlCenter"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleExecutable</key><string>YYavicControlCenter</string>
  <key>CFBundleIdentifier</key><string>com.yyavic.ControlCenter</string>
  <key>CFBundleName</key><string>YYavic Control Center</string>
  <key>CFBundleDisplayName</key><string>YYavic Control Center</string>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleLocalizations</key><array><string>en</string><string>tr</string><string>de</string><string>fr</string><string>es</string><string>it</string><string>pt-BR</string><string>pt-PT</string><string>ru</string><string>cs</string><string>da</string><string>nb</string><string>sv</string><string>fi</string><string>hu</string><string>pl</string><string>ja</string><string>ko</string><string>zh-Hans</string><string>zh-Hant</string></array>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>$VERSION</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHumanReadableCopyright</key><string>Copyright (C) 2026 Yusufcan Yavic. GPL-3.0-or-later.</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
python3 -I localize/gen_strings.py "$APP/Contents/Resources"
codesign --force --sign - "$APP"
# command line tools
swiftc -O -swift-version 5 -target $ARCH-apple-macos13.0 src/ITE8291.swift src/main.swift -o build/yycc-kb
swiftc -O -swift-version 5 -target $ARCH-apple-macos13.0 src/probe.swift -o build/ite8291-probe
echo "built: $APP, build/yycc-kb, build/ite8291-probe"
