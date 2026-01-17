#!/usr/bin/env -S nvim -l

-- Test: Class rename (rename file and class)

local test_util = dofile(vim.fn.expand("~/serhii.home/personal/git/test-java-project/tests/java-refactor-util/helpers/test-util.lua"))
local java_refactor = test_util.setup()

print("=== Test: Class Rename ===")

local project_root = vim.fn.expand("~/serhii.home/personal/git/test-java-project")
vim.fn.chdir(project_root)

-- Setup test files
local src_file = project_root .. "/src/main/java/com/example/OldService.java"
local dst_file = project_root .. "/src/main/java/com/example/NewService.java"

-- Create source file
test_util.create_java_file(src_file, "com.example", "OldService")
print("✓ Created test file: " .. src_file)

-- Rename the file manually
os.rename(src_file, dst_file)
print("✓ Renamed file to: " .. dst_file)

-- Register and process the change
java_refactor.register_change(src_file, dst_file)
local success = java_refactor.process_registerd_changes()

if not success then
    print("✗ Refactoring failed")
    os.exit(1)
end

-- Verify class name was updated
test_util.assert_contains(dst_file, "public class NewService", "Class name not updated")
print("✓ Class name updated")

-- Verify old class name is gone
test_util.assert_not_contains(dst_file, "public class OldService", "Old class name still present")
print("✓ Old class name removed")

-- Verify package remains the same
test_util.assert_contains(dst_file, "package com%.example;", "Package declaration changed unexpectedly")
print("✓ Package declaration unchanged")

-- Cleanup
test_util.cleanup({dst_file})

print("\n✓ Test passed!")
