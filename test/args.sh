test_invalid_compiler_command_line() {
    clang-ctags nosuchfile &&
    fail "Expected clang-ctags to fail" || true
}
