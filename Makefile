check: test/macros.o
	test/run-tests.sh

test/macros.o: test/macros.cpp
	clang++ -c $< -o $@
