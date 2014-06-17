# Integration tests with vim.

test_basic_tags_with_vim() {
    clang-ctags macros.cpp
    assert_vim 0 n1::s macros.cpp:7
}
