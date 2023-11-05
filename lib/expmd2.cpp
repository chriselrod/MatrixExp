#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d2(Dual<double, 2> *A, ptrdiff_t N) {
  expm(A, N);
}
}
