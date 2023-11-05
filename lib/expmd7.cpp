#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d7(Dual<double, 7> *A, ptrdiff_t N) {
  expm(A, N);
}
}
