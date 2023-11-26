#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d4(Dual<double, 4, true> *A, ptrdiff_t N) {
  expm(A, N);
}
}
