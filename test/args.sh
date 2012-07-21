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
    clang-etags $(srcfile "int i;")
    assert_tag i
}

test_dash_e_output_file_name() {
    clang-ctags -e $(srcfile "int i;")
    [ -f TAGS ] || fail "Didn't create 'TAGS'"
}

test_etags_output_file_name() {
    clang-etags $(srcfile "int i;")
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

test_compiler_command_line_linking_multiple_source_files_XFAIL() {
    # The command line accepted by clang-ctags seems to be the command line for
    # the compiler, not the compiler driver (which invokes the compiler proper,
    # assembler, and linker). It means we can't generate tags for several
    # source files in a single clang-ctags invocation (except by using
    # --compile-comands).
    ! clang-ctags -e -- -shared class.cpp overload.cpp
}

test_all_headers() {
    clang-ctags -e -- g++ include.cpp
    assert_no_tag 'in_header()'
    clang-ctags -e --all-headers -- g++ include.cpp
    assert_tag 'in_header()'
    assert_tag '::time_t'
}

test_non_system_headers() {
    clang-ctags -v -e --non-system-headers -- g++ include.cpp
    assert_tag 'in_header()'
    assert_no_tag '::time_t'
}

test_non_system_headers_with_absolute_path_to_source_file() {
    clang-ctags -e --non-system-headers -- g++ "$PWD/include.cpp"
    assert_tag 'in_header()'
    assert_no_tag '::time_t'
}

test_suppress_qualifier_tags() {
    clang-ctags -e struct.cpp
    assert_tag ::s::i
    assert_tag s::i
    assert_tag i
    clang-ctags -e --suppress-qualifier-tags struct.cpp
    assert_tag ::s::i
    assert_no_tag s::i
    assert_no_tag i
}
