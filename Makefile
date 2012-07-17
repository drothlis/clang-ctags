TEST_SOURCES := test/macros.cpp
TEST_SOURCES += test/nested.cpp
TEST_SOURCES += test/overload.cpp

check: $(TEST_SOURCES:%.cpp=%.o) test/compile_commands.json clang-etags
	test/run-tests.sh

$(TEST_SOURCES:%.cpp=%.o): %.o: %.cpp
	clang++ -c $(TEST_CXXFLAGS) $< -o $@
test/overload.o: TEST_CXXFLAGS = -Wno-return-type

test/compile_commands.json: test/compile_commands.json.in
	sed -e "s,@TESTDIR@,$$PWD/test," $< > $@
