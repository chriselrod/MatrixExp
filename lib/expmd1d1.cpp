#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d1d1(DDual<1, 1> *A, DDual<1, 1> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
