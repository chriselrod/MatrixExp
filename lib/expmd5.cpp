#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d5(Dual<double, 5, true> *A, ptrdiff_t N) {
  expm(A, N);
}
}
