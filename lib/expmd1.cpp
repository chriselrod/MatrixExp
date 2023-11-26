#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d1(Dual<double, 1, true> *A, ptrdiff_t N) {
  expm(A, N);
}
}
