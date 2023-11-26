#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d3d2(DDual<3, 2> *A, ptrdiff_t N) {
  expm(A, N);
}
}
