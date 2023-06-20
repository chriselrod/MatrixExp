#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d7(Dual<double, 7> *A, Dual<double, 7> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
