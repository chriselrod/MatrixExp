#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d5d2(DDual<5, 2> *A, DDual<5, 2> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
