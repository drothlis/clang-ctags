TEST_SOURCES := test/macros.cpp
TEST_SOURCES += test/overload.cpp

check: $(TEST_SOURCES:%.cpp=%.o)
	test/run-tests.sh

$(TEST_SOURCES:%.cpp=%.o): %.o: %.cpp
	clang++ -c $(TEST_CXXFLAGS) $< -o $@
test/overload.o: TEST_CXXFLAGS = -Wno-return-type
