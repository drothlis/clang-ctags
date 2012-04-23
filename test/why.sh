# Prove that we need a better etags.

test_traditional_etags_doesnt_expand_macros() {
    etags macros.cpp
    assert_emacs '(find-tag "n1::s")' ""
}

test_traditional_etags_doesnt_differentiate_overloaded_functions() {
    etags overload.cpp
    assert_emacs '(find-tag "foo(int)")' ""
}

# TODO: C++ cases where etags fails -- complex nested types, templates, etc.

# Prove that the tags-file user (emacs) will understand the format I intend to
# generate.
test_emacs_understands_namespace_scopes() {
    cat > TAGS <<-EOF
	$FF
	macros.cpp,
	struct s ${DEL}n1::s${SOH}7,132
	EOF
    assert_emacs '(find-tag "n1::s")' macros.cpp:7
    assert_emacs '(find-tag "s")' macros.cpp:7
}

test_emacs_understands_overloaded_functions() {
    cat > TAGS <<-EOF
	$FF
	overload.cpp,
	int foo(${DEL}foo()${SOH}1,0
	int foo(${DEL}foo(int)${SOH}2,14
	int foo(${DEL}foo(int, int)${SOH}3,33
	float foo(${DEL}foo(float)${SOH}4,59
	EOF

    # Current etags functionality:
    # `M-. foo RET` takes you to the first foo();
    # then `C-u M-.` takes you to the next one, foo(int);
    # `M-. foo RET` goes back to the first foo().
    assert_emacs '(find-tag "foo")' overload.cpp:1
    assert_emacs '(find-tag "foo") (find-tag "foo" t)' overload.cpp:2
    assert_emacs '(find-tag "foo")' overload.cpp:1

    # New functionality allowed by the above TAGS file.
    assert_emacs '(find-tag "foo(int)")' overload.cpp:2
    assert_emacs '(find-tag "foo()")' overload.cpp:1
    assert_emacs '(find-tag "foo(int, int)")' overload.cpp:3
    assert_emacs '(find-tag "foo(float)")' overload.cpp:4

    # Tab-completion within the Emacs find-tag command.
    assert_emacs '' \
        "(sort (all-completions \"foo\" (tags-lazy-completion-table))
               'string<)" \
        '(foo() foo(float) foo(int) foo(int, int))'
}
