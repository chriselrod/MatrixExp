#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d8d1(DDual<8, 1> *A, DDual<8, 1> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
