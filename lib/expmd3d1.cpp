#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d3d1(DDual<3, 1> *A, DDual<3, 1> *B, ptrdiff_t N) {
  expm(A, B, N);
}
}
