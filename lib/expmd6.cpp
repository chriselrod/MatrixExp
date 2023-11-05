#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d6(Dual<double, 6> *A, ptrdiff_t N) {
  expm(A, N);
}
}
