#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d8d1(DDual<8, 1> *A, ptrdiff_t N) {
  expm(A, N);
}
}
