#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d4d2(DDual<4, 2> *A, DDual<4, 2> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
