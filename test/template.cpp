template <typename T>
class B {
public:
    T member;

    template <typename U>
    T method(U param) {
        return member;
    }
};
