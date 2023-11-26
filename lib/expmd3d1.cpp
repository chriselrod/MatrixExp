#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d3d1(DDual<3, 1> *A, ptrdiff_t N) {
  expm(A, N);
}
}
