#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d1(Dual<double, 1> *A, Dual<double, 1> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
