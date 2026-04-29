#!/bin/bash
# skylight-cli installer
# Usage: curl -fsSL https://raw.githubusercontent.com/SIN-CLIs/skylight-cli/main/scripts/install.sh | bash

set -e

REPO="SIN-CLIs/skylight-cli"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

echo "=== skylight-cli installer ==="
echo ""

# Check macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: skylight-cli only works on macOS"
    exit 1
fi

# Check macOS version
MACOS_MAJOR=$(sw_vers -productVersion | cut -d. -f1)
if [ "$MACOS_MAJOR" -lt 12 ]; then
    echo "Error: macOS 12+ required (you have $(sw_vers -productVersion))"
    exit 1
fi

# Create install dir
mkdir -p "$INSTALL_DIR"

# Clone and build
TEMP_DIR=$(mktemp -d)
echo "Cloning repository..."
git clone --depth 1 "https://github.com/$REPO.git" "$TEMP_DIR" 2>/dev/null

echo "Building..."
cd "$TEMP_DIR"
swift build -c release

echo "Installing to $INSTALL_DIR..."
cp ".build/release/skylight" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/skylight"

# Cleanup
rm -rf "$TEMP_DIR"

# Check PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "Note: $INSTALL_DIR is not in your PATH"
    echo "Add this to your shell config:"
    echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
fi

echo ""
echo "Done! Run: skylight help"
echo ""
echo "Next steps:"
echo "1. Grant Accessibility permissions to your terminal"
echo "2. Grant Screen Recording permissions to your terminal"
echo "   (System Preferences > Security & Privacy > Privacy)"
