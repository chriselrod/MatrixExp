#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d2d2(DDual<2, 2> *A, DDual<2, 2> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
