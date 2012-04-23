set -e

fail() { echo FAIL: $*; return 1; }
debug() { echo $* >&2; }

emacs_find_tag() {
    local tag="$1"
    emacs -Q --batch --eval "(progn
        (visit-tags-table \"TAGS\")
        (find-tag \"$tag\")
        (princ (format \"%s:%d\"
                       (file-name-nondirectory buffer-file-name)
                       (line-number-at-pos))))" \
        2>/dev/null
}

assert_find_tag() {
    local tag="$1"
    local expected="$2"
    local output="$(emacs_find_tag "$tag")"
    debug emacs_find_tag $tag : $output
    [ "$output" == "$expected" ] ||
        fail "Didn't find tag '$tag': Expected '$expected', got '$output'"
}

cd "$(dirname "$0")"
rm -f TAGS
etags macros.cpp

# Make sure that the C++ files are valid and that the test system is working.
clang++ -c macros.cpp || fail "macros.cpp doesn't compile"
assert_find_tag s macros.cpp:7

# Prove that etags doesn't expand macros.
assert_find_tag n1::s ""
# TODO: C++ cases where etags fails -- complex nested types, templates, etc.

# Prove that the tags-file user (emacs) will understand the format I intend to
# generate.
FF=$'\x0c'
DEL=$'\x7f'
SOH=$'\x01'
cat > TAGS <<-EOF
	$FF
	macros.cpp,
	struct s ${DEL}n1::s${SOH}7,132
	EOF
assert_find_tag n1::s macros.cpp:7
assert_find_tag s macros.cpp:7
