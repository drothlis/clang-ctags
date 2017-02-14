prefix ?= /usr/local
INSTALL ?= install
TAR ?= tar  # Must be GNU tar.
RST2MAN ?= rst2man

# Generate version from 'git describe' when in git repository, and from
# VERSION file included in the dist tarball otherwise.
generate_version := $(shell \
    git describe --always --dirty > VERSION.now 2>/dev/null && \
    { cmp VERSION.now VERSION 2>/dev/null || mv VERSION.now VERSION; }; \
    rm -f VERSION.now)
VERSION ?= $(shell cat VERSION)

TEST_SCRIPTS := test/run-tests.sh
TEST_SCRIPTS += test/args.sh
TEST_SCRIPTS += test/compile_commands.sh
TEST_SCRIPTS += test/emacs.sh
TEST_SCRIPTS += test/tags.sh
TEST_SCRIPTS += test/why.sh

TEST_SOURCES := test/class.cpp
TEST_SOURCES += test/compile_commands.json.in
TEST_SOURCES += test/enum.cpp
TEST_SOURCES += test/function-locals.cpp
TEST_SOURCES += test/include.cpp
TEST_SOURCES += test/include.h
TEST_SOURCES += test/linkage.cpp
TEST_SOURCES += test/macros.cpp
TEST_SOURCES += test/nested.cpp
TEST_SOURCES += test/overload.cpp
TEST_SOURCES += test/struct.cpp
TEST_SOURCES += $(wildcard test/subdir/[a-f].cpp)
TEST_SOURCES += test/subdir/b2.cpp
TEST_SOURCES += test/subdir/b.h
TEST_SOURCES += test/template.cpp
TEST_SOURCES += test/union.cpp


all: clang-etags doc

doc: clang-ctags.1 clang-etags.1

install: clang-etags clang-ctags.1 clang-etags.1
	$(INSTALL) -m 0755 -d $(DESTDIR)$(prefix)/{bin,share/man/man1}
	$(INSTALL) -m 0755 clang-{c,e}tags $(DESTDIR)$(prefix)/bin
	$(INSTALL) -m 0644 clang-{c,e}tags.1 $(DESTDIR)$(prefix)/share/man/man1

check: $(TEST_SOURCES:%.cpp=%.o) test/compile_commands.json clang-etags
	test/run-tests.sh

# Can only be run from within a git repository of clang-ctags or VERSION won't
# be set correctly.
dist: clang-ctags-$(VERSION).tar.gz


# Requires python-docutils.
clang-ctags.1: README.rst
	sed -e 's/@VERSION@/$(VERSION)/g' $< |\
	sed -e '/\.\. image::/,/^$$/ d' |\
	$(RST2MAN) > $@

clang-etags:
	ln -sf clang-ctags clang-etags
clang-etags.1: clang-ctags.1
	ln -sf clang-ctags.1 clang-etags.1


# "make check" also compiles the C++ files used in test/*.sh to ensure they
# contain valid C++ code.
$(filter %.o,$(TEST_SOURCES:%.cpp=%.o)): %.o: %.cpp
	clang++ -c $(TEST_CXXFLAGS) $< -o $@
test/overload.o: TEST_CXXFLAGS = -Wno-return-type

test/compile_commands.json: test/compile_commands.json.in
	realpath=$$(python2 -c "import os; print os.path.realpath('$$PWD')"); \
	sed -e "s,@TESTDIR@,$$realpath/test," $< > $@


clang-ctags-$(VERSION).tar.gz: \
  clang-ctags Makefile README.rst VERSION $(TEST_SCRIPTS) $(TEST_SOURCES)
	@$(TAR) --version | grep -q GNU || { \
	    echo "Requires GNU tar; use 'TAR=gnutar make dist'" >&2; exit 1; }
	$(TAR) -c -z --transform='s,^,clang-ctags-$(VERSION)/,' -f $@ $^


distcheck: clang-ctags-$(VERSION).tar.gz
	scratchdir=$(shell mktemp -d -t clang-ctags-distcheck.XXX) && \
	trap "rm -rf $$scratchdir" EXIT && \
	$(TAR) -C"$$scratchdir" -xzf $< && \
	cd "$$scratchdir/clang-ctags-$(VERSION)" && \
	make check && \
	{ current=$$(cat clang-ctags |\
	             sed -ne 's/^ *version="clang-ctags \(.*\)")/\1/p') && \
	  [ "$$current" = "$(VERSION)" ] || { \
	    echo "Incorrect version '$$current' in clang-ctags;" \
	         "expected '$(VERSION)'" >&2; \
	    exit 1; }; \
	}


clean:
	rm -rf clang-etags clang-ctags.1 clang-etags.1 \
	    $(filter %.o,$(TEST_SOURCES:%.cpp=%.o)) \
	    test/TAGS test/tags test/subdir/TAGS test/tags.custom-name \
	    test/tmp.cpp test/logs test/compile_commands.json

.PHONY: all check clean dist doc install
