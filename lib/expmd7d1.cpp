#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d7d1(DDual<7, 1> *A, ptrdiff_t N) {
  expm(A, N);
}
}
