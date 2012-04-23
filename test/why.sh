# Prove that we need a better etags.

test_traditional_etags_doesnt_expand_macros() {
    etags macros.cpp
    assert_emacs '(find-tag "n1::s")' ""
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
