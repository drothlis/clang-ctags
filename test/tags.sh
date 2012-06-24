test_basic_tags() {
    clang-ctags -e macros.cpp
    assert_tag n1 6,120
    assert_tag s 7,139
}

test_implicit_declarations_arent_tagged() {
    clang-ctags -e macros.cpp
    assert_no_tag __int128_t
    assert_no_tag __va_list_tag

    # Sanity check:
    assert_tag n1 6,120
}

test_header_files_arent_tagged() {
    clang-ctags -e include.cpp
    assert_no_tag in_header

    # Sanity check:
    clang-ctags -e include.h
    assert_tag "in_header()" 1,5
}

test_macro_expansion() {
    clang-ctags -e macros.cpp
    assert_tag n1 6,120
    assert_tag n1::s 7,139
}

test_function_locals_arent_tagged() {
    clang-ctags -e function-locals.cpp
    assert_no_tag x
    assert_no_tag i

    # Sanity check:
    assert_tag "foo(int)" 1,4
}

test_overloaded_functions() {
    clang-ctags -e overload.cpp
    assert_tag "foo()" 1,4
    assert_tag "foo(int)" 2,18
    assert_tag "foo(int, int)" 3,37
    assert_tag "foo(float)" 4,65
}

test_parameter_qualifiers() {
    clang-ctags -e overload.cpp
    assert_tag "bar(const int *const)" 6,88
}

test_nested_scopes() {
    clang-ctags -e nested.cpp

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
    clang-ctags -e struct.cpp
    assert_tag s::i 2,19
    assert_tag s::j 2,22
    assert_tag s::s 3,35
}

test_union_members() {
    clang-ctags -e union.cpp
    assert_tag u 1,6
    assert_tag u::i 2,18
    assert_tag u::j 3,29
    assert_tag u::s 4,42
}

test_enum_members() {
    clang-ctags -e enum.cpp
    assert_tag E 1,5
    assert_tag E::FIRST 2,13
    assert_tag E::SECOND 3,28
    assert_tag E::LAST 4,40
}

test_class_members() {
    clang-ctags -e class.cpp
    assert_tag A 1,6
    assert_tag A::member 3,26
    assert_tag "A::inline_method()" 6,92
    assert_tag A::type 7,138
    assert_tag "A::method()" 10,155
    assert_tag "A::static_method()" 11,185
}

test_class_access_specifier_not_tagged() {
    clang-ctags -e class.cpp
    assert_no_tag A:: 2,

    # Sanity check:
    assert_tag A 1,6
}

test_class_template() {
    clang-ctags -e template.cpp
    assert_tag "B<T>" 2,28
}

test_templated_scope() {
    clang-ctags -e template.cpp
    assert_tag "B<T>::member" 4,46
}

test_method_template() {
    clang-ctags -e template.cpp
    assert_tag "B<T>::method(U)" 7,87
}

test_invalid_source_file_isnt_tagged() {
    clang-ctags -e $(srcfile "booyah i;") &&
    fail "Expected clang-ctags to fail" || true
}

test_compiler_warnings_dont_prevent_tags() {
    clang-ctags -e $(srcfile "int foo() { }")
    assert_tag "foo()"
}
