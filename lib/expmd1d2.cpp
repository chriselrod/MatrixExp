#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d1d2(DDual<1, 2> *A, DDual<1, 2> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
