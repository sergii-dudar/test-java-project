# Integration Test: Sibling File Move and Restore

This is a comprehensive integration test that validates the entire refactoring workflow using real project files.

## What This Test Does

1. **Moves two sibling files** from their original location to a test subdirectory:
   - `service/MarkerInterface.java` → `service/test/MarkerInterface.java`
   - `service/ServiceEmployee.java` → `service/test/ServiceEmployee.java`

2. **Runs refactoring** to update:
   - Package declarations in moved files
   - All import statements in other files (e.g., `Main.java`)
   - Cross-references between the moved files

3. **Verifies compilation** after the move

4. **Moves files back** to original location

5. **Runs refactoring again** to restore everything

6. **Verifies** that files are exactly as they were before the test

7. **Verifies final compilation**

## Test Scenarios Covered

✅ **Sibling dependencies** - ServiceEmployee implements MarkerInterface
✅ **Import updates** - Main.java imports both files
✅ **Bidirectional refactoring** - Move forward and backward
✅ **State preservation** - Files match original state exactly
✅ **Compilation verification** - Project compiles at each step

## Running the Test

### Quick run:
```bash
cd tests/java-refactor-util
./run-integration-test.sh
```

### Manual run:
```bash
nvim -l test-integration-sibling-move.lua
```

### With headless mode:
```bash
nvim --headless -c "luafile test-integration-sibling-move.lua" -c "qa"
```

## Files Involved

### Files being moved (real project files):
- `src/main/java/com/example/EmployeeManagementSystem/service/MarkerInterface.java`
- `src/main/java/com/example/EmployeeManagementSystem/service/ServiceEmployee.java`

### Files with references to moved files:
- `src/main/java/com/example/EmployeeManagementSystem/Main.java` (imports both)
- `ServiceEmployee.java` (implements MarkerInterface)

## Expected Behavior

### After forward refactoring (service → service.test):
```java
// MarkerInterface.java
package com.example.EmployeeManagementSystem.service.test;  // ← Updated

// ServiceEmployee.java
package com.example.EmployeeManagementSystem.service.test;  // ← Updated

// Main.java
import com.example.EmployeeManagementSystem.service.ServiceEmployee;      // ← Updated
import com.example.EmployeeManagementSystem.service.MarkerInterface;      // ← Updated
```

### After backward refactoring (service.test → service):
```java
// Everything restored to original state
package com.example.EmployeeManagementSystem.service;
```

## Debugging

If the test fails:

1. **Check the refactoring log:**
   ```bash
   tail -50 ~/.local/state/nvim/java-refactor.log
   ```

2. **Manually inspect the files:**
   ```bash
   cat src/main/java/com/example/EmployeeManagementSystem/service/MarkerInterface.java
   ```

3. **Check for leftover test directory:**
   ```bash
   ls -la src/main/java/com/example/EmployeeManagementSystem/service/test/
   ```

4. **Verify compilation:**
   ```bash
   mvn compile
   # or
   ./gradlew compileJava
   ```

## Safety

This test is **safe to run multiple times** because:
- It saves original file content before starting
- It verifies restoration at the end
- It cleans up the test directory
- It exits with error if anything goes wrong (files remain in known state)

## Platform Support

✅ macOS
✅ Linux

The refactoring module automatically detects the OS and uses appropriate commands.
