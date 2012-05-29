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

test_header_files_arent_tagged() {
    clang-ctags include.cpp > TAGS
    assert_no_tag in_header

    # Sanity check:
    clang-ctags include.h > TAGS
    assert_tag in_header 1,5
}

test_macro_expansion() {
    clang-ctags macros.cpp > TAGS
    assert_tag n1 6,120
    assert_tag n1::s 7,139
}

test_nested_scopes() {
    clang-ctags nested.cpp > TAGS

    assert_tag ::n1 1,10
    assert_tag n1 1,10

    assert_tag ::n1::n2 2,27
    assert_tag n1::n2 2,27
    assert_tag n2 2,27
    assert_no_tag ::n2 2,

    assert_tag ::n1::n2::s 3,43
    assert_tag n1::n2::s 3,43
    assert_tag n2::s 3,43
    assert_tag s 3,43
    assert_no_tag ::n2::s 3,
    assert_no_tag ::s 3,

    assert_tag ::n2::s 7,80
    assert_tag n2::s 7,80
    assert_tag s 7,80
    assert_no_tag ::s 7,

    assert_tag ::s 9,96
    assert_tag s 9,96
}
