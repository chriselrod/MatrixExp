#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d6(Dual<double, 6> *A, Dual<double, 6> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
