#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {

static_assert(sizeof(DDual<7, 2>) == size_t(7 + 1) * (2 + 1) * sizeof(double));

void __attribute__((visibility("default")))
expmf64d7d2(DDual<7, 2> *A, DDual<7, 2> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
