#!/bin/bash
# skylight-cli smoke tests
# Runs basic functionality tests

set -e

BINARY=".build/release/skylight"
PASS=0
FAIL=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

pass() { echo -e "${GREEN}[PASS]${NC} $1"; PASS=$((PASS + 1)); }
fail() { echo -e "${RED}[FAIL]${NC} $1"; FAIL=$((FAIL + 1)); }

echo "=== skylight-cli smoke tests ==="
echo ""

# Check binary exists
if [ ! -f "$BINARY" ]; then
    echo "Binary not found at $BINARY"
    echo "Run: make release"
    exit 1
fi

# Test 1: Version command
echo "Test: version command"
OUTPUT=$($BINARY version 2>&1)
if echo "$OUTPUT" | grep -q '"version"'; then
    pass "version returns JSON with version field"
else
    fail "version command: $OUTPUT"
fi

# Test 2: Help command
echo "Test: help command"
OUTPUT=$($BINARY help 2>&1)
if echo "$OUTPUT" | grep -q "screenshot"; then
    pass "help lists commands"
else
    fail "help command: $OUTPUT"
fi

# Test 3: Unknown command exits 2
echo "Test: unknown command"
set +e
$BINARY unknown_command_xyz 2>&1
EXIT_CODE=$?
set -e
if [ $EXIT_CODE -eq 2 ]; then
    pass "unknown command exits with code 2"
else
    fail "unknown command exit code: $EXIT_CODE (expected 2)"
fi

# Test 4: Missing PID exits 2
echo "Test: missing --pid"
set +e
OUTPUT=$($BINARY get-window-state 2>&1)
EXIT_CODE=$?
set -e
if [ $EXIT_CODE -eq 2 ] && echo "$OUTPUT" | grep -q "missing_pid"; then
    pass "missing --pid exits 2 with error code"
else
    fail "missing --pid: exit=$EXIT_CODE output=$OUTPUT"
fi

# Test 5: Invalid PID format exits 2
echo "Test: invalid --pid"
set +e
OUTPUT=$($BINARY get-window-state --pid abc 2>&1)
EXIT_CODE=$?
set -e
if [ $EXIT_CODE -eq 2 ] && echo "$OUTPUT" | grep -q "invalid_pid"; then
    pass "invalid --pid exits 2 with error code"
else
    fail "invalid --pid: exit=$EXIT_CODE output=$OUTPUT"
fi

# Test 6: JSON output validity (requires jq)
if command -v jq &> /dev/null; then
    echo "Test: JSON validity"
    OUTPUT=$($BINARY version 2>&1)
    if echo "$OUTPUT" | jq . > /dev/null 2>&1; then
        pass "version output is valid JSON"
    else
        fail "version output is not valid JSON: $OUTPUT"
    fi
else
    echo "[SKIP] JSON validity (jq not installed)"
fi

# Test 7: Real window test (if Finder running)
FINDER_PID=$(pgrep -n "Finder" || echo "")
if [ -n "$FINDER_PID" ]; then
    echo "Test: get-window-state with Finder (PID $FINDER_PID)"
    set +e
    OUTPUT=$($BINARY get-window-state --pid "$FINDER_PID" 2>&1)
    EXIT_CODE=$?
    set -e
    if [ $EXIT_CODE -eq 0 ] && echo "$OUTPUT" | grep -q '"status": "ok"'; then
        pass "get-window-state works with Finder"
    elif echo "$OUTPUT" | grep -q "ax_access_denied"; then
        echo "[SKIP] get-window-state (no Accessibility permission)"
    else
        fail "get-window-state: exit=$EXIT_CODE output=$OUTPUT"
    fi
else
    echo "[SKIP] Real window test (Finder not running)"
fi

# Summary
echo ""
echo "=== Results ==="
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"

if [ $FAIL -gt 0 ]; then
    exit 1
fi
