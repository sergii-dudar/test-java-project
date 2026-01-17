#!/usr/bin/env -S nvim -l

-- Example test for java-refactor-util
-- Run with: nvim -l tests/example-test.lua
-- Or: nvim --headless -c "luafile tests/example-test.lua" -c "qa"

-- Add your dotfiles to the runtime path
vim.opt.runtimepath:append(vim.fn.expand("~/dotfiles/nvim/.config/nvim"))

-- Require the module
local java_refactor = require("utils.java.java-refactor-util")

-- Enable test mode (executes commands directly without UI)
java_refactor.test_mode = true

print("=== Java Refactor Test ===")
print("Testing package move refactoring...")

-- Define test files (adjust paths as needed)
local project_root = vim.fn.expand("~/serhii.home/personal/git/test-java-project")
local src_file = project_root .. "/src/main/java/com/example/UserService.java"
local dst_file = project_root .. "/src/main/java/com/example/service/UserService.java"

-- Change to project directory
vim.fn.chdir(project_root)

-- Register the change
print("Registering change: " .. src_file .. " -> " .. dst_file)
java_refactor.register_change(src_file, dst_file)

-- Process the changes
print("Processing refactoring...")
local success = java_refactor.process_registerd_changes()

if success then
    print("✓ Refactoring commands executed successfully")

    -- Verify the package declaration was updated
    local file = io.open(dst_file, "r")
    if file then
        local content = file:read("*all")
        file:close()

        if content:match("package com%.example%.service;") then
            print("✓ Package declaration updated correctly")
        else
            print("✗ Package declaration NOT updated")
            os.exit(1)
        end
    else
        print("✗ Destination file not found: " .. dst_file)
        os.exit(1)
    end

    print("\n=== All tests passed! ===")
    os.exit(0)
else
    print("✗ Refactoring failed")
    os.exit(1)
end
