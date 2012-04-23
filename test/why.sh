# Prove that we need a better etags.

test_traditional_etags_doesnt_expand_macros() {
    etags macros.cpp
    assert_emacs '(find-tag "n1::s")' ""
}

test_traditional_etags_doesnt_differentiate_overloaded_functions() {
    etags overload.cpp
    assert_emacs '(find-tag "foo(int)")' ""
}

# TODO: More C++ cases where etags fails -- templates?

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

test_emacs_understands_nested_scopes() {
    # Standard etags already generates something like:
    # struct s ${DEL}n1::n2::s${SOH}3,32
    etags nested.cpp
    assert_emacs '(find-tag "n1::n2::s")' nested.cpp:3
    assert_emacs '(find-tag "s")' nested.cpp:3
    # ...but Emacs won't find n1::n2::s when asked for "n2::s"
    assert_emacs '(find-tag "n2::s")' nested.cpp:7
    assert_emacs '(find-tag "n2::s") (find-tag "n2::s" t)' ""

    # So we can either:
    #
    # 1. Use Emacs's find-tag-regexp. This would require modifying
    #    find-tag-regexp-tag-order in etags.el to match the explicit tagname,
    #    not just the pattern (see etc/ETAGS.EBNF in the Emacs source tree for
    #    an explanation of this terminology and of the TAGS file format). Or,
    #
    # 2. Generate multiple entries for s, as follows:
    cat > TAGS <<-EOF
	$FF
	nested.cpp,
	    struct s ${DEL}::n1::n2::s${SOH}3,32
	    struct s ${DEL}n1::n2::s${SOH}3,32
	    struct s ${DEL}n2::s${SOH}3,32
	    struct s ${DEL}s${SOH}3,32
	  struct s ${DEL}::n2::s${SOH}7,71
	  struct s ${DEL}n2::s${SOH}7,71
	  struct s ${DEL}s${SOH}7,71
	struct s ${DEL}::s${SOH}9,89
	struct s ${DEL}s${SOH}9,89
	EOF
    assert_emacs '(find-tag "n1::n2::s")' nested.cpp:3
    assert_emacs '(find-tag "n2::s")' nested.cpp:3
    assert_emacs '(find-tag "n2::s") (find-tag "n2::s" t)' nested.cpp:7
    assert_emacs '(find-tag "::n2::s")' nested.cpp:7
    assert_emacs '(find-tag "::s")' nested.cpp:9
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
