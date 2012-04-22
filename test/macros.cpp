// Yes this is stupid, but people really do it
#define NS_N1 n1
#define NS_N1_START namespace n1 {
#define NS_N1_END }

NS_N1_START
struct s { };
NS_N1_END
