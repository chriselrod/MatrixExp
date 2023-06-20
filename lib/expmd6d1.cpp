#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d6d1(DDual<6, 1> *A, DDual<6, 1> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
