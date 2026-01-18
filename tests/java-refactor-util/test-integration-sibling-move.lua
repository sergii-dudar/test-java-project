#!/usr/bin/env -S nvim -l

-- Test: Integration test - Move sibling files to subdirectory and back
-- This test:
-- 1. Moves MarkerInterface.java and ServiceEmployee.java to test/ subdirectory
-- 2. Runs refactoring to update all references
-- 3. Verifies compilation
-- 4. Moves files back to original location
-- 5. Runs refactoring again
-- 6. Verifies everything is back to original state and compiles

local test_util = dofile(vim.fn.expand("~/serhii.home/personal/git/test-java-project/tests/java-refactor-util/helpers/test-util.lua"))
local java_refactor = test_util.setup()

print("=== Integration Test: Sibling Move and Restore ===")

local project_root = vim.fn.expand("~/serhii.home/personal/git/test-java-project")
vim.fn.chdir(project_root)

-- Define file paths
local base_dir = project_root .. "/src/main/java/com/example/EmployeeManagementSystem/service"
local test_subdir = base_dir .. "/test"

local marker_src = base_dir .. "/MarkerInterface.java"
local marker_dst = test_subdir .. "/MarkerInterface.java"

local employee_src = base_dir .. "/ServiceEmployee.java"
local employee_dst = test_subdir .. "/ServiceEmployee.java"

-- Verify source files exist
print("\n1. Verifying source files exist...")
test_util.assert_file_exists(marker_src)
test_util.assert_file_exists(employee_src)
print("✓ Source files exist")

-- Create temporary Main.java for testing import updates
local main_java_path = project_root .. "/src/main/java/com/example/EmployeeManagementSystem/Main.java"
local main_java_content = [[package com.example.EmployeeManagementSystem;

import com.example.EmployeeManagementSystem.service.ServiceEmployee;
import com.example.EmployeeManagementSystem.service.MarkerInterface;

/**
 * Main class that uses the service classes
 * This will verify that refactoring updates imports correctly
 */
public class Main {
    public static void main(String[] args) {
        System.out.println("Test class for refactoring");
    }
}
]]
local main_file = io.open(main_java_path, "w")
main_file:write(main_java_content)
main_file:close()
print("✓ Created temporary Main.java for testing")

-- Save original content for later comparison
local marker_original = io.open(marker_src, "r"):read("*all")
local employee_original = io.open(employee_src, "r"):read("*all")
print("✓ Saved original file contents")

-- Verify initial package declaration
test_util.assert_contains(marker_src, "package com%.example%.EmployeeManagementSystem%.service;", "Original MarkerInterface package incorrect")
test_util.assert_contains(employee_src, "package com%.example%.EmployeeManagementSystem%.service;", "Original ServiceEmployee package incorrect")
print("✓ Original package declarations verified")

-- Step 1: Move files to test subdirectory
print("\n2. Moving files to test/ subdirectory...")
vim.fn.mkdir(test_subdir, "p")
os.rename(marker_src, marker_dst)
os.rename(employee_src, employee_dst)
print("✓ Files moved to:", test_subdir)

-- Step 2: Register and process refactoring (forward)
print("\n3. Running refactoring (service -> service.test)...")
java_refactor.register_change(marker_src, marker_dst)
java_refactor.register_change(employee_src, employee_dst)
local success = java_refactor.process_registerd_changes()

if not success then
    print("✗ Forward refactoring failed")
    os.exit(1)
end
print("✓ Refactoring completed")

-- Step 3: Verify package declarations were updated
print("\n4. Verifying package declarations updated...")
test_util.assert_contains(marker_dst, "package com%.example%.EmployeeManagementSystem%.service%.test;", "MarkerInterface package not updated")
test_util.assert_contains(employee_dst, "package com%.example%.EmployeeManagementSystem%.service%.test;", "ServiceEmployee package not updated")
print("✓ Package declarations updated correctly")

-- Step 4: Verify class declarations remain unchanged
print("\n5. Verifying class names unchanged...")
test_util.assert_contains(marker_dst, "interface MarkerInterface", "MarkerInterface name changed")
test_util.assert_contains(employee_dst, "class ServiceEmployee", "ServiceEmployee name changed")
print("✓ Class names unchanged")

-- Step 5: Verify compilation after forward refactoring
print("\n6. Verifying compilation after forward refactoring...")
test_util.verify_compilation(project_root)
print("✓ Compilation successful")

-- Step 6: Move files back to original location
print("\n7. Moving files back to original location...")
os.rename(marker_dst, marker_src)
os.rename(employee_dst, employee_src)
print("✓ Files moved back to:", base_dir)

-- Step 7: Register and process refactoring (backward)
print("\n8. Running refactoring (service.test -> service)...")
java_refactor.register_change(marker_dst, marker_src)
java_refactor.register_change(employee_dst, employee_src)
success = java_refactor.process_registerd_changes()

if not success then
    print("✗ Backward refactoring failed")
    os.exit(1)
end
print("✓ Refactoring completed")

-- Step 8: Verify package declarations restored
print("\n9. Verifying package declarations restored...")
test_util.assert_contains(marker_src, "package com%.example%.EmployeeManagementSystem%.service;", "MarkerInterface package not restored")
test_util.assert_contains(employee_src, "package com%.example%.EmployeeManagementSystem%.service;", "ServiceEmployee package not restored")
print("✓ Package declarations restored")

-- Step 9: Verify files are back to original state
print("\n10. Verifying files match original state...")
local marker_current = io.open(marker_src, "r"):read("*all")
local employee_current = io.open(employee_src, "r"):read("*all")

if marker_current ~= marker_original then
    print("✗ MarkerInterface.java does not match original state")
    print("Expected length:", #marker_original)
    print("Current length:", #marker_current)
    os.exit(1)
end

if employee_current ~= employee_original then
    print("✗ ServiceEmployee.java does not match original state")
    print("Expected length:", #employee_original)
    print("Current length:", #employee_current)
    os.exit(1)
end
print("✓ Files match original state exactly")

-- Step 10: Verify final compilation
print("\n11. Verifying final compilation...")
test_util.verify_compilation(project_root)
print("✓ Final compilation successful")

-- Cleanup test directory and temporary files
print("\n12. Cleaning up...")
os.remove(test_subdir)
os.remove(main_java_path)
print("✓ Test directory and temporary files removed")

print("\n" .. string.rep("=", 50))
print("✓ ALL INTEGRATION TESTS PASSED!")
print(string.rep("=", 50))
print("\nSummary:")
print("  - Moved 2 sibling files to subdirectory")
print("  - Refactored all references (forward)")
print("  - Verified compilation")
print("  - Moved files back to original location")
print("  - Refactored all references (backward)")
print("  - Verified files match original state")
print("  - Verified final compilation")
