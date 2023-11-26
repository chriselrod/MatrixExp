#pragma once
#include <Containers/TinyVector.hpp>
#include <Math/Array.hpp>
#include <Math/Dual.hpp>
#include <Math/LinearAlgebra.hpp>
#include <Math/Matrix.hpp>
#include <Utilities/Invariant.hpp>
#include <algorithm>
#include <bit>
#include <cstdint>
#include <ranges>
#include <utility>

namespace poly::math {

static_assert(std::convertible_to<int, Dual<double, 4>>);
static_assert(std::convertible_to<int, Dual<Dual<double, 4>, 2>>);

template <typename T>
constexpr void evalpoly(MutSquarePtrMatrix<T> B, MutSquarePtrMatrix<T> A,
                        SquarePtrMatrix<T> C, const auto &p) {
  ptrdiff_t N = p.size();
  invariant(N > 0);
  invariant(ptrdiff_t(B.numRow()), ptrdiff_t(C.numRow()));
  if (N & 1) std::swap(A, B);
  B << p[0] * C + p[1] * I;
  for (ptrdiff_t i = 2; i < N; ++i) {
    std::swap(A, B);
    B << A * C + p[i] * I;
  }
}

template <AbstractMatrix T> constexpr auto opnorm1(const T &A) {
  using S = decltype(value(std::declval<utils::eltype_t<T>>()));
  auto [M, N] = shape(A);
  invariant(M > 0);
  invariant(N > 0);
  S a{};
  for (ptrdiff_t n = 0; n < N; ++n) {
    S s{};
    for (ptrdiff_t m = 0; m < M; ++m) s += std::abs(value(A[m, n]));
    a = std::max(a, s);
  }
  return a;
  // Vector<S> v{N};
  // for (ptrdiff_t n = 0; n < N; ++n)
  //   v[n] = std::abs(value(A[0, n]));
  // for (ptrdiff_t m = 1; m < M; ++m)
  //   for (ptrdiff_t n = 0; n < N; ++n)
  //     v[n] += std::abs(value(A[m, n]));
  // return *std::max_element(v.begin(), v.end());
}

/// computes ceil(log2(x)) for x >= 1
constexpr auto log2ceil(double x) -> ptrdiff_t {
  invariant(x >= 1);
  uint64_t u = std::bit_cast<uint64_t>(x) - 1;
  auto y = ptrdiff_t((u >> 52) - 1022);
  invariant(y >= 0);
  return y;
}
/*
inline void show(double x) { std::cout << x; }
template <typename T, ptrdiff_t N> inline void show(Dual<T, N> x) {
  std::cout << "Dual<N>(v = ";
  show(x.value());
  std::cout << ", p = {";
  show(x.gradient()[0]);
  for (ptrdiff_t n = 1; n < N; ++n) {
    std::cout << ", ";
    show(x.gradient()[n]);
  }
  std::cout << "})";
}
template <typename T> void show(SquarePtrMatrix<T> A, const char *name) {
  ptrdiff_t N = ptrdiff_t(A.numCol());
  for (ptrdiff_t r = 0; r < N; ++r) {
    for (ptrdiff_t c = 0; c < N; ++c) {
      std::cout << name << "[" << r << ", " << c << "] = ";
      show(A[r, c]);
      std::cout << "\n";
    }
  }
  std::cout << "\n";
}
*/
template <typename T> constexpr void expm(MutSquarePtrMatrix<T> A) {
  ptrdiff_t n = ptrdiff_t(A.numRow()), s = 0;
  SquareMatrix<T> A2{SquareDims<>{{n}}}, U_{SquareDims<>{{n}}};
  MutSquarePtrMatrix<T> U{U_};
  if (double nA = opnorm1(A); nA <= 0.015) {
    A2 << A * A;
    U << A * (A2 + 60.0 * I);
    A << 12.0 * A2 + 120.0 * I;
  } else {
    SquareMatrix<T> B{SquareDims<>{{n}}};
    if (nA <= 2.1) {
      A2 << A * A;
      containers::TinyVector<double, 5> p0, p1;
      if (nA > 0.95) {
        p0 = {1.0, 3960.0, 2162160.0, 302702400.0, 8821612800.0};
        p1 = {90.0, 110880.0, 3.027024e7, 2.0756736e9, 1.76432256e10};
      } else if (nA > 0.25) {
        p0 = {1.0, 1512.0, 277200.0, 8.64864e6};
        p1 = {56.0, 25200.0, 1.99584e6, 1.729728e7};
      } else {
        p0 = {1.0, 420.0, 15120.0};
        p1 = {30.0, 3360.0, 30240.0};
      }
      evalpoly(B, U, A2, p0);
      U << A * B;
      evalpoly(A, B, A2, p1);
    } else {
      // s = std::max(unsigned(std::ceil(std::log2(nA / 5.4))), 0);
      s = nA > 5.4 ? log2ceil(nA / 5.4) : 0;
      if (s & 1) {       // we'll swap `U` and `A` an odd number of times
        std::swap(A, U); // so let them switch places
        A << U * exp2(-s);
      } else if (s > 0) A *= exp2(-s);
      A2 << A * A;
      // here we take an estrin (instead of horner) approach to cut down flops
      SquareMatrix<T> A4{A2 * A2}, A6{A2 * A4};
      B << A6 * (A6 + 16380 * A4 + 40840800 * A2) +
             (33522128640 * A6 + 10559470521600 * A4 + 1187353796428800 * A2) +
             32382376266240000 * I;
      U << A * B;
      A << A6 * (182 * A6 + 960960 * A4 + 1323241920 * A2) +
             (670442572800 * A6 + 129060195264000 * A4 +
              7771770303897600 * A2) +
             64764752532480000 * I;
    }
  }
  containers::tie(A, U) << containers::Tuple(A + U, A - U);
  LU::ldiv(U, MutPtrMatrix<T>(A));
  for (; s--; std::swap(A, U)) U << A * A;
}
template <typename T> void expm(T *A, ptrdiff_t M) {
  expm(MutSquarePtrMatrix<utils::decompressed_t<T>>(A, SquareDims<>{{M}}));
}

} // namespace poly::math

using poly::math::expm, poly::math::Dual;
template <size_t N, size_t M>
using DDual = Dual<Dual<double, N, true>, M, true>;
static_assert(sizeof(DDual<4, 2>) == size_t(4 + 1) * (2 + 1) * sizeof(double));
static_assert(sizeof(Dual<double, 4, true>) == size_t(4 + 1) * sizeof(double));

static_assert(
  std::same_as<
    double, decltype(poly::math::opnorm1(
              std::declval<poly::math::MutSquarePtrMatrix<DDual<7, 2>>>()))>);
