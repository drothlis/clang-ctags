#!/bin/bash

set -e  # Exit immediately if any unexpected error occurs
unset GREP_OPTIONS

fail() { echo FAIL: $*; exit 1; }
debug() { echo $* >&2; }

assert_emacs() {
    local forms print expected
    forms="$1"
    case $# in
        2) expected="$2";;
        3) print="(princ $2)"; expected="$3";;
        *) return 1;;
    esac
    : ${print:='(princ (format "%s:%d"
                               (file-name-nondirectory buffer-file-name)
                               (line-number-at-pos)))'}

    local output=$(
        emacs -Q --batch --eval "(progn
            (visit-tags-table \"TAGS\")
            $forms
            $print)")
    debug $forms : $output
    [ "$output" == "$expected" ] ||
        fail "$forms: Expected '$expected', got '$output'"
}

assert_tag() {
    local tagname="$1" position="$2"
    local search="$DEL$tagname$SOH"
    [ -z "$position" ] || search+="$position"
    grep -q -F "$search" TAGS ||
        fail "No tag '$tagname' '$position' in TAGS"
}
assert_no_tag() {
    local tagname="$1" position="${2:-}"
    ! grep -q "$DEL$tagname$SOH$position" TAGS ||
        fail "Unexpected tag '$tagname' in TAGS: $(
            grep "$DEL$tagname$SOH$position" TAGS | head -1)"
}

srcfile() {
    echo "$*" > tmp.cpp
    echo "tmp.cpp"
}

FF=$'\x0c'
DEL=$'\x7f'
SOH=$'\x01'

test_the_test_framework() {
    etags macros.cpp
    assert_emacs '(find-tag "s")' macros.cpp:7
    assert_emacs '(find-tag "idontexist")' ""
}

##############################################################################

# portable 'readlink --canonicalize'
realpath() { python -c "import os; print os.path.realpath('$1')"; }

cd "$(realpath "$(dirname "$0")")"
testdir=$(pwd)

for f in $(ls *.sh | grep -v $(basename $0)); do
    source ./$f
done

testcases="$*"
failures=0
for t in ${testcases:-$(declare -F | awk '/ test_/ { print $3 }')}; do
    ( # Run each test in a sub-shell to minimise side-effects.
        set +e  # So that a failing test doesn't terminate this sub-shell.
        printf "$t ... "
        logfile=logs/$t.log
        mkdir -p "$(dirname $logfile)"
        rm -f TAGS tags
        ( set -e; PATH="$testdir/..:$PATH" $t; ) &> $logfile
        status=$?
        [ $status -eq 0 ] && echo "OK" || { echo "FAIL"; cat $logfile; echo; }
        exit $status
    ) \
    || failures=$((failures+1))
done

[ $failures -eq 0 ]
exit


# bash-completion script: Add the below to ~/.bash_completion
_clang_ctags_run_tests() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local testdir="$(dirname \
        $(echo $COMP_LINE | grep -o '\b[^ ]*run-tests\.sh\b'))"
    local testfiles="$(\ls $testdir/*.sh | grep -v run-tests.sh)"
    local testcases="$(awk -F'[() ]' '/^test_/ {print $1}' $testfiles)"
    COMPREPLY=( $(compgen -W "$testcases" -- "$cur" ) )
}
complete -F _clang_ctags_run_tests run-tests.sh
