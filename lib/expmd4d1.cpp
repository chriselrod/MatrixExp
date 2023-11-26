#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d4d1(DDual<4, 1> *A, ptrdiff_t N) {
  expm(A, N);
}
}
