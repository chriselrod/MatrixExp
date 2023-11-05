#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d8(Dual<double, 8> *A, ptrdiff_t N) {
  expm(A, N);
}
}
