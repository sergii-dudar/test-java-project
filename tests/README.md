# Test Suite for Java Development Tools

This directory contains automated tests for various Java development utilities and tools.

## Test Suites

### 📦 java-refactor-util
Tests for the Neovim Java refactoring utility (`java-refactor-util.lua`).

**Location:** `tests/java-refactor-util/`

**Run tests:**
```bash
cd tests/java-refactor-util
./run-tests.sh
```

See [java-refactor-util/README.md](java-refactor-util/README.md) for details.

## Adding New Test Suites

To add tests for new functionality:

1. Create a new directory: `tests/your-tool-name/`
2. Add your test files and test runner
3. Document in a README.md
4. Update this file with a link

## Structure

```
tests/
├── README.md                    # This file
├── java-refactor-util/          # Java refactoring tests
│   ├── run-tests.sh
│   ├── test-*.lua
│   ├── helpers/
│   └── README.md
└── (future test suites...)
```

## Requirements

- Neovim (for running Lua tests)
- Bash (for test runners)
- Java/Maven/Gradle (for compilation verification)

## Platform Support

All tests are designed to work on:
- ✅ macOS
- ✅ Linux
