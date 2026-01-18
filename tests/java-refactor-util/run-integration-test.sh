#!/usr/bin/env bash

# Run the integration test for sibling file move and restore
# This test moves real files, refactors them, and restores them

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../.."
TEST_FILE="$SCRIPT_DIR/test-integration-sibling-move.lua"

echo "==================================="
echo "Integration Test: Sibling Move"
echo "==================================="
echo "Project: $PROJECT_ROOT"
echo "OS: $(uname -s)"
echo "-----------------------------------"

# Check if source files exist
if [[ ! -f "$PROJECT_ROOT/src/main/java/com/example/EmployeeManagementSystem/service/MarkerInterface.java" ]]; then
    echo "✗ Error: MarkerInterface.java not found"
    exit 1
fi

if [[ ! -f "$PROJECT_ROOT/src/main/java/com/example/EmployeeManagementSystem/service/ServiceEmployee.java" ]]; then
    echo "✗ Error: ServiceEmployee.java not found"
    exit 1
fi

echo "✓ Source files found"
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
echo "Running integration test..."
echo "-----------------------------------"

# Run the test
if nvim --headless -c "luafile $TEST_FILE" -c "qa" 2>&1; then
    echo ""
    echo "==================================="
    echo "✓ INTEGRATION TEST PASSED"
    echo "==================================="
    exit 0
else
    echo ""
    echo "==================================="
    echo "✗ INTEGRATION TEST FAILED"
    echo "==================================="
    echo ""
    echo "Check the log for details:"
    echo "  tail ~/.local/state/nvim/java-refactor.log"
    exit 1
fi
