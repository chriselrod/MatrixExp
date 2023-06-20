#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d6d2(DDual<6, 2> *A, DDual<6, 2> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
