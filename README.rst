=============
 clang-ctags
=============

-------------------------------------
Generate tag file for C++ source code
-------------------------------------

:Copyright: Copyright (c) 2012 David Rothlisberger.
:Author: David Rothlisberger <david@rothlis.net>
:License: UIUC license (a BSD-like license; the same license as Clang).
          See LICENSE file in source distribution for details.
:Version: @VERSION@
:Manual section: 1
:Manual group: Clang Tools Documentation


SYNOPSIS
========

clang-ctags [options] -- *compilation command line*

clang-ctags [options] --compile-commands *path/to/compile_commands.json*
                      *source-file* [*source-file*...]


DESCRIPTION
===========

**clang-ctags** and **clang-etags** generate (in a format understood by Vi and
Emacs, respectively) a "tag" file indexing the C++ definitions found in the
specified files.

(Hereafter both variants will be collectively referred to as clang-ctags,
except where distiguished.)

Note that only the Emacs (etags) format is currently implemented.

Unlike other ctags implementations, clang-ctags uses a real C++ compiler
(clang) to parse source files, allowing for more accurate indexing. (C++ is
notoriously difficult to parse, and other ctags implementations rely on
heuristics to disambiguate certain constructs.) Unlike other implementations,
clang-ctags only understands C and C++ source files; and because clang-ctags
needs to run each source file through the C pre-processor, its usage is
somewhat more complicated than other ctags implementations.


OPTIONS
=======

The command-line interface of clang-ctags is *not* compatible with GNU etags,
Exuberant Ctags, or other existing ctags implementations. This is because
clang-ctags needs the full compilation command line to pass on to clang.

-a, --append
    Append tag entries to existing tag file.

-e
    Output tags in Emacs format (the default is Vi format).
    Implied if the program name contains "etags".

-o tagfile, -f tagfile
    Write the tags to *tagfile*; "-" writes tags to stdout
    (the default is "tags", or "TAGS" when -e supplied).

-v, --verbose
    Print debugging information to stderr.

--version
    Print version identifier to stdout, and exit. This is guaranteed to always
    contain the string "clang-ctags".

--compile-commands *path/to/compile_commands.json*
    A "compilation database" containing the compilation command line for every
    source file in your project. See **Compilation database**, below.

--all-headers
    Write tags for all header files encountered while preprocessing the source
    file(s), not just the headers specified on the command line. Note that if
    you include any system headers (even indirectly) this will result in a very
    large tag file; I recommend you only use this option when generating a tag
    file for a single source file.

--non-system-headers
    Write tags for all non-system header files encountered while preprocessing
    the source file(s), not just the headers specified on the command line. (A
    system header file is one found in certain system-dependent directories and
    included with `<header.h>` instead of `"header.h"`.)
    libclang doesn't currently expose the list of system directories, so
    clang-ctags employs the following heuristic to decide that a file is *not*
    a system header: (a) the file is found via a relative path (as specified to
    the preprocessor with `-I`), or (b) the file is located under the directory
    where clang-ctags is run from. Note that (b) is necessary because clang
    converts all header search paths to absolute paths if the source filename
    (as specified on the compiler command line) is an absolute path.

--suppress-qualifier-tags
    Write a single tag per C++ definition, instead of separate tags for each
    level of namespace/class qualifiers. For example, given a source file
    containing ``namespace ns { class cls { int member; }; }`` clang-ctags will
    generate 4 separate tags: `::ns::cls::member`, `ns::cls::member`,
    `cls::member`, and `member`. When this option is given, only the first of
    those tags will be generated.


COMPILATION COMMAND LINE
========================

When called with the form **clang-ctags -- compilation command line**, the
`compilation command line` is the full command line that you would pass to the
C++ compiler if you were to compile the source file, excluding the name of the
C++ compiler itself (i.e. argv[0]). This form can only process one source file
per invocation, and is useful for running clang-ctags during a build.

When called with the form
**clang-ctags --compile-commands=compile_commands.json**, the compilation
command line is taken from the specified file, described in **Compilation
database**, below.

In reality clang-ctags only needs the preprocessor flags (`-I`, `-D`, etc.) and
the name of the source file, but it is often easier to pass the full
compilation command line; clang-ctags will ignore linker flags and most
compiler flags.

Interposing the compiler to run clang-ctags during the build
------------------------------------------------------------

Most Unix makefile-based build systems allow the user to specify a compiler in
the CC and CXX `make` variables. You can point these variables to a script that
invokes clang-ctags, and then invokes the real compiler::

    #!/bin/sh
    clang-ctags -f tagfile --append -- "$@"
    g++ "$@"

Note that this is only useful when starting from a clean build and an empty tag
file, because `clang-ctags --append` doesn't remove previous tags for a file
that it has already processed. So you would end up with the up-to-date tags at
the end of the tag file; Emacs will use the first, out of date, tag it finds.

Note that autoconf-generated `configure` scripts create makefiles with
hard-coded paths to the compiler, so you will need to set CC and CXX when
running `configure`.

Prior art for this technique:

* clang itself has a perl script called `scan-build` that invokes the clang
  static analyser with the full compilation command line. You run it with::

    scan-build make

  http://clang-analyzer.llvm.org/scan-build.html
  http://llvm.org/svn/llvm-project/cfe/trunk/tools/scan-build/scan-build

* `clang_complete`, a Vim plugin for code completion, provides a python script
  called `cc_args.py` that saves compilation command lines into a database (in
  clang_complete's own custom format, not the format we describe below). You
  run it with::

    make CC='cc_args.py gcc' CXX='cc_args.py g++'

  https://github.com/Rip-Rip/clang_complete/blob/master/bin/cc_args.py
  https://github.com/Rip-Rip/clang_complete/blob/master/doc/clang_complete.txt#L237

* `gccsense`, a code completion tool based on gcc, provides a ruby script
  called `gccrec` that is similar in usage and function to clang_complete's
  cc_args.py.

  http://cx4a.org/software/gccsense/manual.html#gccrec

Compilation database
--------------------

If you build your C++ project with CMake, you can generate a database of
compilation commands with::

    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1

The format of this compilation database is documented at
http://clang.llvm.org/docs/JSONCompilationDatabase.html.

clang-ctags understands the format of this database (and so do some other
clang-based tools).

If you don't use cmake, and you're feeling energetic, you could even write a
script that uses the technique from the previous section, to generate a
compilation database in this format. (If you do, let me know!)


INSTALLING
==========

**clang-ctags** requires *libclang* version 3.2 or greater, and the libclang
*python bindings* (libclang and its python bindings are both part of the
official clang project).

libclang and its python bindings may be available from your system's package
manager (probably in the *clang* or *clang-devel* package). You can test the
python bindings by running the *python* interpreter and typing::

    import clang.cindex

If you see a python ImportError, you will need to build clang from source (see
http://clang.llvm.org/get_started.html), point LD_LIBRARY_PATH at the built
*libclang.so* (on OS X: DYLD_LIBRARY_PATH and libclang.dylib), and point
PYTHONPATH at *bindings/python/* in the clang source directory.

Please help me out by pestering your system's maintainers to include libclang
and its python bindings in the official clang package for your system (Debian,
Ubuntu, FreeBSD, MacPorts, etc).


PERFORMANCE
===========

Running clang-ctags over the `lib` directory of the `clang` source code (480
files totalling 470k lines of code) took 4.3 minutes on a 1.8GHz Intel Core i7.
72% of this time is the parsing done by libclang itself (the calls to
clang_parseTranslationUnit, or clang.cindex.Index.parse in the python
bindings). The result is a 3MB tag file with 23k tags.

By comparison, GNU etags takes 0.5 **seconds** on the same input and produces
a 1.4MB tag file with 25k tags.

(The command line used was::

    time find llvm/tools/clang/lib -name '*.[ch]' -o -name '*.[ch]pp' |
    xargs clang-ctags -v -e --suppress-qualifier-tags \
          --compile-commands=build/compile_commands.json

clang-ctags didn't generate tags for any of the header files in `lib/Headers`,
because no source files included them. GNU etags generated about 4k tags from
these header files.)

Running clang-ctags over a much larger input, such as the entire llvm C/C++
sources (7k files, 1.8 million lines of code) took 98 minutes and a peak memory
usage of 140MB.

A better solution would be to run clang-ctags over a single source file at a
time, as part of the build (see "Interposing the compiler to run clang-ctags
during the build", above), using `--append` to update an existing tag file.
This would require modifying clang-ctags so that, when appending, it reads
in the tag file and removes existing tags for the same source file.


HACKING
=======

The `clang-ctags` source file is light on comments but there is a lot of
information in the commit messages, which I have tried to structure in a
tutorial-like fashion. Start by browsing the oldest commits at
https://github.com/drothlis/clang-ctags/commits/master/clang-ctags
and make good use of `git annotate`.


SEE ALSO
========

* http://github.com/drothlis/clang-ctags
* http://clang.llvm.org/
