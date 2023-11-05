#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d2d2(DDual<2, 2> *A, ptrdiff_t N) {
  expm(A, N);
}
}
