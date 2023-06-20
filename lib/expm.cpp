#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64(double *A, double *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
