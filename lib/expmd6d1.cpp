#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d6d1(DDual<6, 1> *A, ptrdiff_t N) {
  expm(A, N);
}
}
