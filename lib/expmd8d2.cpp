#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d8d2(DDual<8, 2> *A, DDual<8, 2> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
