#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d8(Dual<double, 8> *A, Dual<double, 8> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
