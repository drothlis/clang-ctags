template <typename T, typename U>
class B {
public:
    T member;

    template <typename V>
    T method(V param) {
        return member;
    }
};

// template specialisation
template <>
class B<int, int> {
public:
    int member;
    int method(int param) {
        return member;
    }
};

// template partial specialisation
template <typename T>
class B<T, int> {
public:
    T member;
    T method(int param) {
        return member;
    }
};
