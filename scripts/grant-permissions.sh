#!/bin/bash
# skylight-cli permission helper
# Opens System Preferences to the right panes

set -e

echo "=== skylight-cli permission helper ==="
echo ""
echo "skylight-cli needs two macOS permissions:"
echo "1. Accessibility - to read UI element data"
echo "2. Screen Recording - to capture window screenshots"
echo ""

# Detect terminal app
TERMINAL_APP="Terminal"
if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    TERMINAL_APP="iTerm"
elif [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    TERMINAL_APP="Terminal"
elif [[ -n "$TERM_PROGRAM" ]]; then
    TERMINAL_APP="$TERM_PROGRAM"
fi

echo "Detected terminal: $TERMINAL_APP"
echo ""

# Open Accessibility preferences
echo "Opening Accessibility preferences..."
echo "Add '$TERMINAL_APP' to the list and enable the checkbox."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

read -p "Press Enter after granting Accessibility permission..."

# Open Screen Recording preferences
echo ""
echo "Opening Screen Recording preferences..."
echo "Add '$TERMINAL_APP' to the list and enable the checkbox."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"

read -p "Press Enter after granting Screen Recording permission..."

echo ""
echo "Done! You may need to restart your terminal for changes to take effect."
echo ""
echo "Test with: skylight doctor"
