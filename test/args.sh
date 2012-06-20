# Test command-line arguments

test_help() {
    clang-ctags -h || fail "Incorrect exit status '$?'"
    clang-ctags -h | grep usage || fail "No usage message"
}

test_output_file() {
    rm -f tags.custom-name
    clang-ctags -e -o tags.custom-name -- $(srcfile "int i;")
    [ -f tags.custom-name ] || fail "Didn't create 'tags.custom-name'"
}

test_output_to_stdout() {
    clang-ctags -e -o - -- $(srcfile "int i;") > TAGS
    assert_tag i
}

test_append() {
    clang-ctags -e -- $(srcfile "int i;")
    assert_tag i
    clang-ctags -e -a -- $(srcfile "int j;")
    assert_tag i
    assert_tag j
}

test_dash_e_format() {
    clang-ctags -e $(srcfile "int i;")
    assert_tag i
}

test_etags_format() {
    ln -sf $(which clang-ctags) ./clang-etags
    ./clang-etags $(srcfile "int i;")
    assert_tag i
}

test_dash_e_output_file_name() {
    clang-ctags -e $(srcfile "int i;")
    [ -f TAGS ] || fail "Didn't create 'TAGS'"
}

test_etags_output_file_name() {
    ln -sf $(which clang-ctags) ./clang-etags
    ./clang-etags $(srcfile "int i;")
    [ -f TAGS ] || fail "Didn't create 'TAGS'"
}

test_no_compiler_command_line() {
    clang-ctags && fail "Expected clang-ctags to fail" || true
}

test_invalid_compiler_command_line() {
    clang-ctags -- nosuchfile &&
    fail "Expected clang-ctags to fail" || true
}

test_preprocessor_flags_passed_through() {
    clang-ctags -e -- g++ -DMYMACRO=i $(srcfile "int MYMACRO;")
    assert_tag i
}
