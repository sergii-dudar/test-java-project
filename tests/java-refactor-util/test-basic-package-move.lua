#!/usr/bin/env -S nvim -l

-- Test: Basic package move (move file to subdirectory)

local test_util = dofile(vim.fn.expand("~/serhii.home/personal/git/test-java-project/tests/java-refactor-util/helpers/test-util.lua"))
local java_refactor = test_util.setup()

print("=== Test: Basic Package Move ===")

local project_root = vim.fn.expand("~/serhii.home/personal/git/test-java-project")
vim.fn.chdir(project_root)

-- Setup test files
local src_file = project_root .. "/src/main/java/com/example/service/TestService.java"
local dst_file = project_root .. "/src/main/java/com/example/service/TestService.java"

-- Create source file
test_util.create_java_file(src_file, "com.example", "TestService")
print("✓ Created test file: " .. src_file)

-- Move the file manually to simulate file manager action
local dst_dir = dst_file:match("(.+)/[^/]+$")
vim.fn.mkdir(dst_dir, "p")
os.rename(src_file, dst_file)
print("✓ Moved file to: " .. dst_file)

-- Register and process the change
java_refactor.register_change(src_file, dst_file)
local success = java_refactor.process_registerd_changes()

if not success then
    print("✗ Refactoring failed")
    os.exit(1)
end

-- Verify package declaration was updated
test_util.assert_contains(dst_file, "package com%.example%.service;", "Package declaration not updated")
print("✓ Package declaration updated")

-- Verify class name remains the same
test_util.assert_contains(dst_file, "public class TestService", "Class name changed unexpectedly")
print("✓ Class name unchanged")

-- Cleanup
test_util.cleanup({dst_file})
os.remove(dst_dir)

print("\n✓ Test passed!")
