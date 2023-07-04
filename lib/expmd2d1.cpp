#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d2d1(DDual<2, 1> *A, DDual<2, 1> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}