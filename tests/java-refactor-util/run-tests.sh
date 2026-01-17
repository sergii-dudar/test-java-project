#!/usr/bin/env bash

# Test runner for Java refactoring tests
# Works on both macOS and Linux

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==================================="
echo "Java Refactoring Test Suite"
echo "==================================="
echo "Project root: $PROJECT_ROOT"
echo "Tests dir: $TESTS_DIR"
echo "OS: $(uname -s)"
echo "-----------------------------------"

# Track test results
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Function to run a single test
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .lua)

    echo ""
    echo "Running: $test_name"
    echo "-----------------------------------"

    if nvim --headless -c "luafile $test_file" -c "qa" 2>&1; then
        echo "✓ PASSED: $test_name"
        ((TESTS_PASSED++))
    else
        echo "✗ FAILED: $test_name"
        ((TESTS_FAILED++))
        FAILED_TESTS+=("$test_name")
    fi
}

# Run all test files
for test_file in "$TESTS_DIR"/test-*.lua; do
    if [[ -f "$test_file" ]]; then
        run_test "$test_file"
    fi
done

# Print summary
echo ""
echo "==================================="
echo "Test Summary"
echo "==================================="
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
    echo ""
    echo "Failed tests:"
    for test in "${FAILED_TESTS[@]}"; do
        echo "  - $test"
    done
fi

echo "==================================="

# Exit with appropriate code
if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi
