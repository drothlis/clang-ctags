test_db() {
    clang-ctags -e --compile-commands=compile_commands.json subdir/a.cpp
    assert_tag a
}

test_db_with_multiple_source_files() {
    clang-ctags -e --compile-commands=compile_commands.json \
        subdir/a.cpp subdir/b.cpp subdir/b.h
    assert_tag a
    assert_tag b
    assert_emacs '(find-tag "a")' a.cpp:1
    assert_emacs '(find-tag "b")' b.h:1
}
