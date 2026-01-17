-- Test utilities for Java refactoring tests

local M = {}

-- Setup test environment
function M.setup()
    -- Add dotfiles to runtime path
    vim.opt.runtimepath:append(vim.fn.expand("~/dotfiles/nvim/.config/nvim"))

    -- Require the module
    local java_refactor = require("utils.java.java-refactor-util")

    -- Enable test mode
    java_refactor.test_mode = true

    return java_refactor
end

-- Create a test Java file with content
function M.create_java_file(path, package, class_name, content)
    local dir = path:match("(.+)/[^/]+$")
    vim.fn.mkdir(dir, "p")

    content = content or string.format([[
package %s;

public class %s {
    public void doSomething() {
        System.out.println("Hello from %s");
    }
}
]], package, class_name, class_name)

    local file = io.open(path, "w")
    file:write(content)
    file:close()

    return path
end

-- Verify file content contains a pattern
function M.assert_contains(file_path, pattern, error_msg)
    local file = io.open(file_path, "r")
    if not file then
        print("✗ FAIL: File not found: " .. file_path)
        os.exit(1)
    end

    local content = file:read("*all")
    file:close()

    if not content:match(pattern) then
        print("✗ FAIL: " .. error_msg)
        print("  Expected pattern: " .. pattern)
        print("  File: " .. file_path)
        os.exit(1)
    end
end

-- Verify file content does NOT contain a pattern
function M.assert_not_contains(file_path, pattern, error_msg)
    local file = io.open(file_path, "r")
    if not file then
        print("✗ FAIL: File not found: " .. file_path)
        os.exit(1)
    end

    local content = file:read("*all")
    file:close()

    if content:match(pattern) then
        print("✗ FAIL: " .. error_msg)
        print("  Should not contain pattern: " .. pattern)
        print("  File: " .. file_path)
        os.exit(1)
    end
end

-- Verify file exists
function M.assert_file_exists(file_path)
    local file = io.open(file_path, "r")
    if not file then
        print("✗ FAIL: File should exist: " .. file_path)
        os.exit(1)
    end
    file:close()
end

-- Clean up test files
function M.cleanup(paths)
    for _, path in ipairs(paths) do
        os.remove(path)
    end
end

-- Run Maven/Gradle build to verify compilation
function M.verify_compilation(project_root)
    print("Verifying Java compilation...")

    -- Try Maven first
    local mvn_result = os.execute("cd " .. project_root .. " && mvn compile -q 2>&1")
    if mvn_result == 0 or mvn_result == true then
        print("✓ Maven compilation successful")
        return true
    end

    -- Try Gradle
    local gradle_result = os.execute("cd " .. project_root .. " && ./gradlew compileJava -q 2>&1")
    if gradle_result == 0 or gradle_result == true then
        print("✓ Gradle compilation successful")
        return true
    end

    print("⚠ Warning: Could not verify compilation (Maven/Gradle not found or failed)")
    return false
end

return M
