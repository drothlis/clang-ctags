test_basic_tags() {
    clang-ctags macros.cpp > TAGS
    assert_tag n1 6,120
    assert_tag s 7,139
}
