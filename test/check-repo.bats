#!/usr/bin/env bats

# Lightweight BATS test suite for check-repo.sh
# Run with: bats test/check-repo.bats

setup() {
    # Ensure we're in the repo root (where the test files live)
    cd "$(dirname "$BATS_TEST_FILENAME")/.." || exit 1
    # Make sure the script is executable
    chmod +x check-repo.sh 2>/dev/null || true
}

@test "check-repo.sh exists and is executable" {
    [ -f "check-repo.sh" ]
    [ -x "check-repo.sh" ]
}

@test "script runs without errors (exit status 0)" {
    run ./check-repo.sh
    [ "$status" -eq 0 ]
}

@test "detects dangerous patterns (eval, exec, Function, suspicious env vars)" {
    run ./check-repo.sh
    [[ "$output" == *"eval(input)"* ]]
    [[ "$output" == *"child_process.exec"* ]]
    [[ "$output" == *"new Function"* ]]
    [[ "$output" == *"PrivateKey"* ]]
    [[ "$output" == *"WalletAddress"* ]]
}

@test "detects base64 / encoded string obfuscation" {
    run ./check-repo.sh
    [[ "$output" == *"Buffer"* ]]
    [[ "$output" == *"decoder-catch.js"* ]]
}

@test "flags long config files as potential obfuscation" {
    run ./check-repo.sh
    [[ "$output" == *"tailwind.config.js"* ]]
    [[ "$output" == *"webpack.config.js"* ]]
    [[ "$output" == *"babel.config.js"* ]]
    [[ "$output" == *"postcss.config.js"* ]]
    [[ "$output" == *"WARNING: Config > 100 lines"* ]]
}

@test "detects postinstall / preinstall / prepare scripts" {
    run ./check-repo.sh
    [[ "$output" == *"postinstall"* ]]
    [[ "$output" == *"preinstall"* ]]
    [[ "$output" == *"prepare"* ]]
    [[ "$output" == *"ShouldBeCaught"* ]]
}

@test "detects suspicious dependencies (0.0.0 / 0.0.1)" {
    run ./check-repo.sh
    [[ "$output" == *"0.0.0"* ]]
    [[ "$output" == *"0.0.1"* ]]
    [[ "$output" == *"@catchMe/test"* ]]
}

@test "script always ends with === DONE ===" {
    run ./check-repo.sh
    [[ "$output" == *"=== DONE ==="* ]]
}

@test "script includes safety review message" {
    run ./check-repo.sh
    [[ "$output" == *"DO NOT RUN npm install"* ]]
}
