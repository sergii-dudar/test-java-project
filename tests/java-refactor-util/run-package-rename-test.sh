#!/usr/bin/env bash

# Run the integration test for root package rename
# This test renames com.example to ua.sdm.corp.applications and back

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../.."
TEST_FILE="$SCRIPT_DIR/test-integration-package-rename.lua"

echo "==================================="
echo "Integration Test: Package Rename"
echo "==================================="
echo "Project: $PROJECT_ROOT"
echo "OS: $(uname -s)"
echo "-----------------------------------"

# Check if source files exist
if [[ ! -d "$PROJECT_ROOT/src/main/java/com/example" ]]; then
    echo "✗ Error: com.example package not found"
    exit 1
fi

echo "✓ Source package found"
echo ""

# Verify initial compilation
echo "Verifying initial compilation..."
cd "$PROJECT_ROOT"
if mvn clean compile -q 2>&1 | grep -q "BUILD SUCCESS"; then
    echo "✓ Initial compilation successful"
elif ./gradlew clean compileJava -q 2>&1 | grep -q "BUILD SUCCESSFUL"; then
    echo "✓ Initial compilation successful (Gradle)"
else
    echo "⚠ Warning: Could not verify initial compilation"
fi

echo ""
echo "Running package rename test..."
echo "-----------------------------------"

# Run the test
if nvim --headless -c "luafile $TEST_FILE" -c "qa" 2>&1; then
    echo ""
    echo "==================================="
    echo "✓ PACKAGE RENAME TEST PASSED"
    echo "==================================="
    exit 0
else
    echo ""
    echo "==================================="
    echo "✗ PACKAGE RENAME TEST FAILED"
    echo "==================================="
    echo ""
    echo "Check the log for details:"
    echo "  tail ~/.local/state/nvim/java-refactor.log"
    exit 1
fi
