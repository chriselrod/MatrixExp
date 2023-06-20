#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d3(Dual<double, 3> *A, Dual<double, 3> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
