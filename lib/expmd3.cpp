#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d3(Dual<double, 3> *A, ptrdiff_t N) {
  expm(A, N);
}
}
