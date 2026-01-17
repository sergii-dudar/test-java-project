# Java Refactoring Test Suite

Automated tests for the `java-refactor-util.lua` module. Works on both macOS and Linux.

## Quick Start

```bash
cd tests/java-refactor-util
./run-tests.sh
```

## How It Works

Tests use **Neovim headless mode** to:
1. Enable `test_mode` in the refactoring module
2. Call `register_change()` and `process_registerd_changes()` directly
3. Execute commands via `os.execute()` instead of terminal UI
4. Verify results by checking file contents

## Running Tests

### All tests:
```bash
./run-tests.sh
```

### Single test:
```bash
nvim -l test-basic-package-move.lua
```

## Platform Support

✅ macOS (BSD sed)
✅ Linux (GNU sed)

## Test Scenarios

- [x] Move file to subdirectory (package change)
- [x] Rename class (type name change)
- [ ] Move multiple files together (siblings)
- [ ] Move file with imports in other files
- [ ] Compilation verification

See full list in the test files.
