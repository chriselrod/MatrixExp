#include "MatrixExp.hpp"
#include <cstddef>

extern "C" {
void __attribute__((visibility("default")))
expmf64d8d2(DDual<8, 2> *A, ptrdiff_t N) {
  expm(A, N);
}
}
