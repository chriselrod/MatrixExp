#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64(double *A, double *B, ptrdiff_t N) {
  expm(A, B, N);
}

auto __attribute__((visibility("default")))
food(double *A, ptrdiff_t col, ptrdiff_t N) -> double {
  return foo(
    poly::math::DensePtrMatrix<double>{A, poly::math::DenseDims{3, col}}, N);
}
}
