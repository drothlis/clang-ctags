class A {
public:
    int member;
    int method();
    static int static_method();
    int inline_method() { return 0; }
    typedef int type;
};

int A::method() { return 0; }
int A::static_method() { return 0; }

A::type free_function() { return 0; }
