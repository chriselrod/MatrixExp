#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d5d1(DDual<5, 1> *A, DDual<5, 1> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
