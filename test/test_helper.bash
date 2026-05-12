# test/test_helper.bash
setup_file() {
    export REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
}

# Helper to count occurrences
assert_contains() {
    if ! grep -q "$1" <<< "$output"; then
        echo "Expected output to contain: $1" >&2
        return 1
    fi
}
