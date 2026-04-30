#!/bin/bash
# skylight-cli doctor
# Checks system prerequisites and common issues

set -e

echo "=== skylight-cli doctor ==="
echo ""

# Colors (if terminal supports)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

ERRORS=0

# 1. macOS version
echo "Checking macOS version..."
MACOS_VERSION=$(sw_vers -productVersion)
MAJOR=$(echo "$MACOS_VERSION" | cut -d. -f1)
if [ "$MAJOR" -ge 12 ]; then
    pass "macOS $MACOS_VERSION (>= 12 required)"
else
    fail "macOS $MACOS_VERSION (need 12+)"
    ERRORS=$((ERRORS + 1))
fi

# 2. Swift version
echo "Checking Swift..."
if command -v swift &> /dev/null; then
    SWIFT_VERSION=$(swift --version | head -1)
    pass "Swift found: $SWIFT_VERSION"
else
    fail "Swift not found"
    ERRORS=$((ERRORS + 1))
fi

# 3. Xcode command line tools
echo "Checking Xcode CLT..."
if xcode-select -p &> /dev/null; then
    CLT_PATH=$(xcode-select -p)
    pass "Xcode CLT: $CLT_PATH"
else
    fail "Xcode Command Line Tools not installed"
    echo "  Run: xcode-select --install"
    ERRORS=$((ERRORS + 1))
fi

# 4. Accessibility permissions
echo "Checking Accessibility permissions..."
# This is tricky to check programmatically, we do a heuristic
if [ -f ".build/release/skylight" ]; then
    # Try to run a command that needs AX
    if .build/release/skylight get-window-state --pid 1 2>&1 | grep -q "ax_access_denied"; then
        fail "Accessibility access not granted"
        echo "  Go to: System Preferences > Security & Privacy > Privacy > Accessibility"
        echo "  Add: Terminal (or your terminal app)"
        ERRORS=$((ERRORS + 1))
    else
        pass "Accessibility (heuristic check)"
    fi
else
    warn "Binary not built, cannot check Accessibility"
    echo "  Run: make release"
fi

# 5. Screen Recording permissions (needed for screenshots)
echo "Checking Screen Recording permissions..."
# Similar heuristic
if [ -f ".build/release/skylight" ]; then
    TEST_PID=$(pgrep -n "Finder" || echo "")
    if [ -n "$TEST_PID" ]; then
        RESULT=$(.build/release/skylight screenshot --pid "$TEST_PID" --dry-run 2>&1 || true)
        if echo "$RESULT" | grep -q "capture_failed"; then
            fail "Screen Recording not granted"
            echo "  Go to: System Preferences > Security & Privacy > Privacy > Screen Recording"
            echo "  Add: Terminal (or your terminal app)"
            ERRORS=$((ERRORS + 1))
        elif echo "$RESULT" | grep -q '"status": "ok"'; then
            pass "Screen Recording"
        else
            warn "Could not verify Screen Recording"
        fi
    else
        warn "Finder not running, cannot test Screen Recording"
    fi
else
    warn "Binary not built, cannot check Screen Recording"
fi

# 6. SkyLight framework
echo "Checking SkyLight framework..."
if [ -d "/System/Library/PrivateFrameworks/SkyLight.framework" ]; then
    pass "SkyLight.framework exists"
else
    warn "SkyLight.framework not found (may still work via fallback)"
fi

# 7. Build status
echo "Checking build..."
if [ -f ".build/release/skylight" ]; then
    pass "Release binary exists"
    VERSION=$(.build/release/skylight version 2>&1 | grep -o '"version"[^}]*' || echo "unknown")
    echo "  $VERSION"
else
    warn "Release binary not found"
    echo "  Run: make release"
fi

# Summary
echo ""
echo "=== Summary ==="
if [ $ERRORS -eq 0 ]; then
    pass "All checks passed"
    exit 0
else
    fail "$ERRORS issue(s) found"
    exit 1
fi
