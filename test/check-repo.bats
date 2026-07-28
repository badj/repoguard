#!/usr/bin/env bats

# Lightweight BATS test suite for check-repo.sh
# Run with: bats test/check-repo.bats

setup() {
    # Resolve the repo root, then run the script from the fixtures directory
    # (test/fixtures/ mirrors a scanned project's root, so the root-relative
    # config and package.json checks find the sample files)
    REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    CHECK_REPO="$REPO_ROOT/check-repo.sh"
    cd "$REPO_ROOT/test/fixtures" || exit 1
    # Make sure the script is executable
    chmod +x "$CHECK_REPO" 2>/dev/null || true
}

@test "check-repo.sh exists and is executable" {
    [ -f "$CHECK_REPO" ]
    [ -x "$CHECK_REPO" ]
}

@test "script runs without errors (exit status 0)" {
    run "$CHECK_REPO"
    [ "$status" -eq 0 ]
}

@test "detects dangerous patterns (eval, exec, Function, suspicious env vars)" {
    run "$CHECK_REPO"
    [[ "$output" == *"eval(input)"* ]]
    [[ "$output" == *"child_process.exec"* ]]
    [[ "$output" == *"new Function"* ]]
    [[ "$output" == *"PrivateKey"* ]]
    [[ "$output" == *"WalletAddress"* ]]
}

@test "detects base64 / encoded string obfuscation" {
    run "$CHECK_REPO"
    [[ "$output" == *"Buffer"* ]]
    [[ "$output" == *"decoder-catch.js"* ]]
}

@test "flags long config files as potential obfuscation" {
    run "$CHECK_REPO"
    [[ "$output" == *"tailwind.config.js"* ]]
    [[ "$output" == *"webpack.config.js"* ]]
    [[ "$output" == *"babel.config.js"* ]]
    [[ "$output" == *"postcss.config.js"* ]]
    [[ "$output" == *"WARNING: Config > 100 lines"* ]]
}

@test "detects postinstall / preinstall / prepare scripts" {
    run "$CHECK_REPO"
    [[ "$output" == *"postinstall"* ]]
    [[ "$output" == *"preinstall"* ]]
    [[ "$output" == *"prepare"* ]]
    [[ "$output" == *"ShouldBeCaught"* ]]
}

@test "detects suspicious dependencies (0.0.0 / 0.0.1)" {
    run "$CHECK_REPO"
    [[ "$output" == *"0.0.0"* ]]
    [[ "$output" == *"0.0.1"* ]]
    [[ "$output" == *"@catchMe/test"* ]]
}

@test "script always ends with === DONE ===" {
    run "$CHECK_REPO"
    [[ "$output" == *"=== DONE ==="* ]]
}

@test "script includes safety review message" {
    run "$CHECK_REPO"
    [[ "$output" == *"DO NOT RUN npm install"* ]]
}
