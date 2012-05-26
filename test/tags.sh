test_basic_tags() {
    clang-ctags macros.cpp > TAGS
    assert_tag n1 6,120
    assert_tag s 7,139
}

test_implicit_declarations_arent_tagged() {
    clang-ctags macros.cpp > TAGS
    assert_no_tag __int128_t
    assert_no_tag __va_list_tag
}
