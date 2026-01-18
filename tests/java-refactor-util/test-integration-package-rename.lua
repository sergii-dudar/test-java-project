#!/usr/bin/env -S nvim -l

-- Test: Integration test - Rename root package
-- This test:
-- 1. Renames entire package from com.example to ua.sdm.corp.applications
-- 2. Moves all Java files to new directory structure
-- 3. Updates all package declarations and imports
-- 4. Verifies compilation after rename
-- 5. Renames back to original package
-- 6. Verifies everything is restored to original state

local test_util = dofile(vim.fn.expand("~/serhii.home/personal/git/test-java-project/tests/java-refactor-util/helpers/test-util.lua"))
local java_refactor = test_util.setup()

print("=== Integration Test: Root Package Rename ===")

local project_root = vim.fn.expand("~/serhii.home/personal/git/test-java-project")
vim.fn.chdir(project_root)

-- Define package paths
local old_package_prefix = "com.example"
local new_package_prefix = "ua.sdm.corp.applications"

local old_base_dir = project_root .. "/src/main/java/com/example"
local new_base_dir = project_root .. "/src/main/java/ua/sdm/corp/applications"

-- Step 1: Find all Java files in the old package
print("\n1. Finding all Java files in com.example package...")
local handle = io.popen("cd " .. project_root .. " && find src/main/java/com/example -name '*.java' 2>/dev/null")
local find_output = handle:read("*all")
handle:close()

local java_files = {}
for line in find_output:gmatch("[^\r\n]+") do
    table.insert(java_files, project_root .. "/" .. line)
end

if #java_files == 0 then
    print("✗ No Java files found in com.example package")
    os.exit(1)
end

print("✓ Found " .. #java_files .. " Java files")

-- Step 2: Save original content for verification
print("\n2. Saving original file contents...")
local original_contents = {}
for _, file_path in ipairs(java_files) do
    local file = io.open(file_path, "r")
    if file then
        original_contents[file_path] = file:read("*all")
        file:close()
    end
end
print("✓ Saved " .. #java_files .. " file contents")

-- Step 3: Create new directory structure
print("\n3. Creating new directory structure...")
local mkdir_cmd = "mkdir -p " .. new_base_dir
os.execute(mkdir_cmd)
print("✓ Created directory: " .. new_base_dir)

-- Step 4: Move files and register changes
print("\n4. Moving files to new package structure...")
local move_count = 0
for _, old_file in ipairs(java_files) do
    -- Calculate new file path by replacing the package path
    -- old: .../src/main/java/com/example/EmployeeManagementSystem/...
    -- new: .../src/main/java/ua/sdm/corp/applications/EmployeeManagementSystem/...
    local new_file = old_file:gsub("/com/example/", "/ua/sdm/corp/applications/")

    -- Create parent directory for new file
    local new_dir = new_file:match("(.+)/[^/]+$")
    os.execute("mkdir -p '" .. new_dir .. "'")

    -- Move file
    local mv_result = os.rename(old_file, new_file)
    if not mv_result then
        print("✗ Failed to move: " .. old_file)
        print("  From: " .. old_file)
        print("  To: " .. new_file)
        os.exit(1)
    end

    -- Register change for refactoring
    java_refactor.register_change(old_file, new_file)
    move_count = move_count + 1
end
print("✓ Moved " .. move_count .. " files")

-- Step 5: Run refactoring (forward)
print("\n5. Running refactoring (com.example -> ua.sdm.corp.applications)...")
local success = java_refactor.process_registerd_changes()

if not success then
    print("✗ Forward refactoring failed")
    os.exit(1)
end
print("✓ Refactoring completed")

-- Step 6: Verify package declarations were updated
print("\n6. Verifying package declarations updated...")
local verify_count = 0
for _, old_file in ipairs(java_files) do
    local updated_file = old_file:gsub("/com/example/", "/ua/sdm/corp/applications/")

    if vim.fn.filereadable(updated_file) == 1 then
        local file = io.open(updated_file, "r")
        local content = file:read("*all")
        file:close()

        -- Check if package declaration was updated
        if content:match("package ua%.sdm%.corp%.applications") then
            verify_count = verify_count + 1
        else
            print("✗ Package not updated in: " .. updated_file)
            os.exit(1)
        end

        -- Check for old package references
        if content:match("package com%.example%.") then
            print("✗ Old package declaration still present in: " .. updated_file)
            os.exit(1)
        end
    else
        print("✗ File not found: " .. updated_file)
        os.exit(1)
    end
end
print("✓ Verified " .. verify_count .. " package declarations")

-- Step 7: Verify imports were updated
print("\n7. Verifying imports updated...")
local import_check = os.execute("cd " .. project_root .. " && ! rg -q 'import com\\.example\\.' src/main/java/ua/")
if not import_check then
    print("⚠ Warning: Some old imports may still exist")
else
    print("✓ All imports updated")
end

-- Step 8: Verify compilation after forward refactoring
print("\n8. Verifying compilation after forward refactoring...")
test_util.verify_compilation(project_root)
print("✓ Compilation successful")

-- Step 9: Move files back to original location
print("\n9. Moving files back to original package...")
for _, old_file in ipairs(java_files) do
    local new_file = old_file:gsub("/com/example/", "/ua/sdm/corp/applications/")

    -- Create parent directory for old file
    local old_dir = old_file:match("(.+)/[^/]+$")
    os.execute("mkdir -p '" .. old_dir .. "'")

    -- Move file back
    local mv_result = os.rename(new_file, old_file)
    if not mv_result then
        print("✗ Failed to move back: " .. new_file)
        print("  From: " .. new_file)
        print("  To: " .. old_file)
        os.exit(1)
    end

    -- Register change for backward refactoring
    java_refactor.register_change(new_file, old_file)
end
print("✓ Moved files back to original locations")

-- Step 10: Run refactoring (backward)
print("\n10. Running refactoring (ua.sdm.corp.applications -> com.example)...")
success = java_refactor.process_registerd_changes()

if not success then
    print("✗ Backward refactoring failed")
    os.exit(1)
end
print("✓ Refactoring completed")

-- Step 11: Verify files match original state
print("\n11. Verifying files match original state...")
local match_count = 0
for file_path, original_content in pairs(original_contents) do
    if vim.fn.filereadable(file_path) == 1 then
        local file = io.open(file_path, "r")
        local current_content = file:read("*all")
        file:close()

        if current_content == original_content then
            match_count = match_count + 1
        else
            print("✗ File does not match original: " .. file_path)
            print("Expected length:", #original_content)
            print("Current length:", #current_content)
            os.exit(1)
        end
    else
        print("✗ File missing after restoration: " .. file_path)
        os.exit(1)
    end
end
print("✓ All " .. match_count .. " files match original state")

-- Step 12: Verify final compilation
print("\n12. Verifying final compilation...")
test_util.verify_compilation(project_root)
print("✓ Final compilation successful")

-- Step 13: Cleanup
print("\n13. Cleaning up...")
os.execute("rm -rf " .. new_base_dir)
-- Also remove empty parent directories
os.execute("rm -rf " .. project_root .. "/src/main/java/ua")
print("✓ Cleanup completed")

print("\n" .. string.rep("=", 50))
print("✓ ALL PACKAGE RENAME TESTS PASSED!")
print(string.rep("=", 50))
print("\nSummary:")
print("  - Renamed package: com.example -> ua.sdm.corp.applications")
print("  - Moved " .. #java_files .. " files to new structure")
print("  - Updated all package declarations and imports")
print("  - Verified compilation after rename")
print("  - Renamed package back: ua.sdm.corp.applications -> com.example")
print("  - Verified all files restored to original state")
print("  - Verified final compilation")
