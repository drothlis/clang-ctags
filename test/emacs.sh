# Integration tests with Emacs.

test_basic_tags_with_emacs() {
    clang-ctags macros.cpp > TAGS
    assert_emacs '(find-tag "n1::s")' macros.cpp:7
}
