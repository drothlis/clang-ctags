test_db() {
    clang-ctags -e --compile-commands=compile_commands.json subdir/a.cpp
    assert_tag a
}
