#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d7d2(DDual<7, 2> *A, DDual<7, 2> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
