test_db() {
    clang-ctags -e --compile-commands=compile_commands.json "$PWD/subdir/a.cpp"
    assert_tag a
}

test_db_with_multiple_source_files() {
    clang-ctags -e --compile-commands=compile_commands.json \
        "$PWD/subdir/a.cpp" "$PWD/subdir/b.cpp" "$PWD/subdir/b.h"
    assert_tag a
    assert_tag b
    assert_emacs '(find-tag "a")' a.cpp:1
    assert_emacs '(find-tag "b")' b.h:1
}

test_db_find_entry_with_relative_path_XFAIL() {
    # The lookup done by clang's CompilationDatabase.getCompileCommands (C
    # function clang_CompilationDatabase_getCompileCommands) doesn't seem to do
    # anything smart with the filenames, just plain string matches.
    clang-ctags -e --compile-commands=compile_commands.json subdir/c.cpp
    ! ( assert_tag c )
}

test_db_find_entry_with_relative_path_given_absolute_path_XFAIL() {
    clang-ctags -e --compile-commands=compile_commands.json "$PWD/subdir/c.cpp"
    ! ( assert_tag c )
}

test_db_find_entry_with_absolute_path_given_relative_path() {
    clang-ctags -e --compile-commands=compile_commands.json subdir/a.cpp
    assert_tag a
}

test_db_find_entry_with_canonical_path_given_uncanonical_path() {
    ln -sf subdir subdir2
    clang-ctags -e --compile-commands=compile_commands.json subdir2/a.cpp
    assert_tag a
}
