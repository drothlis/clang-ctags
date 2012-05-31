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

test_struct_members() {
    clang-ctags struct.cpp > TAGS
    assert_tag s::i 2,19
    assert_tag s::j 2,22
    assert_tag s::s 3,35
}

test_class_members() {
    clang-ctags class.cpp > TAGS
    assert_tag A 1,6
    assert_tag A::member 3,26
    assert_tag A::inline_method 6,92
    assert_tag A::type 7,138
    assert_tag A::method 10,155
    assert_tag A::static_method 11,185
}

test_class_access_specifier_not_tagged() {
    clang-ctags class.cpp > TAGS
    assert_no_tag A:: 2,
}
